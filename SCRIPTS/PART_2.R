
fnPartIIResults <-
  function(Dmax, Nmax) {
    outcomes <-
      seq.int(from = Nmax - 1L, to = 0L) |>
      purrr::accumulate(
        function (nextTurn, n) {
          # As per the first game variant.
          toProcess <-
            tibble::tibble(
              D = seq.int(Dmax),
              N = n
            ) |>
            tidyr::expand_grid(
              TAKE = c(TRUE, FALSE)
            ) |>
            tidyr::expand_grid(
              nextTurn |>
                dplyr::transmute(
                  NEXT_D = D,
                  NEXT_VALUE = VALUE,
                  NEXT_TAKE = TAKE
                )
            ) |>
            dplyr::arrange(N, D, !TAKE)
          
          toProcess |>
            # Note the requirement that we cannot have 2x consecutive takes.
            dplyr::filter(TAKE, !NEXT_TAKE, D == NEXT_D) |>
            dplyr::mutate(
              VALUE = D + NEXT_VALUE
            ) |>
            dplyr::select(
              N,
              D,
              TAKE,
              VALUE
            ) |>
            dplyr::bind_rows(
              toProcess |>
                dplyr::filter(!TAKE) |>
                dplyr::group_by(
                  N,
                  D,
                  TAKE,
                  NEXT_D
                ) |>
                # Same underlying approach as per the first variant.
                dplyr::summarise(
                  NEXT_VALUE = max(NEXT_VALUE),
                  .groups = 'drop_last'
                ) |>
                dplyr::summarise(
                  VALUE = mean(NEXT_VALUE),
                  .groups = 'drop'
                ) |>
                dplyr::select(
                  N,
                  D,
                  TAKE,
                  VALUE
                )
            )
        },
        .init =
          tibble::tibble(
            N = Nmax,
            D = seq.int(Dmax),
            VALUE = D,
            TAKE = TRUE
          ) |>
          dplyr::bind_rows(
            tibble::tibble(
              N = Nmax,
              D = seq.int(Dmax),
              VALUE = 0.0,
              TAKE = FALSE
            )
          )
      ) |>
      dplyr::bind_rows() |>
      dplyr::filter(
        (N > 0L) | (D == 1L)
      ) |>
      # Prioritise TAKEs.
      dplyr::arrange(N, D, !TAKE)
    
    # Here the strategy derivation is more complex as:
    #  - Not all combinations of play are possible; ie... Cannot have 2x consecutive takes.
    #  - As such... The optimal strategy depends on the chosen action for the previous turn.
    strategy <-
      outcomes |>
      dplyr::filter(N > 0L) |>
      dplyr::group_by(N) |>
      dplyr::group_split() |>
      purrr::accumulate(
        function (priorTurn, currentTurn) {
          priorTurn |>
            dplyr::transmute(
              PRIOR_D = D,
              PRIOR_TAKE = TAKE
            ) |>
            tidyr::expand_grid(
              currentTurn
            ) |>
            dplyr::filter(
              # Again, noting the requirement regarding consecutive takes.
              (PRIOR_TAKE & (!TAKE) & (PRIOR_D == D)) | !PRIOR_TAKE
            ) |>
            dplyr::arrange(N, D, !TAKE) |>
            # Note that the optimal strategy for a given node depends
            # on what happened for the previous turn.
            dplyr::slice_max(
              order_by = VALUE,
              with_ties = FALSE,
              by = c(N, D, PRIOR_TAKE)
            ) |>
            dplyr::select(
              N,
              D,
              VALUE,
              PRIOR_TAKE,
              TAKE
            )
        },
        .init =
          # Go with the most optimal opening action.
          outcomes |>
          dplyr::filter(N == 0L) |>
          dplyr::slice_max(order_by = VALUE, with_ties = FALSE)
      ) |>
      dplyr::bind_rows() |>
      dplyr::arrange(
        N,
        D,
        PRIOR_TAKE,
        TAKE
      )
    
    # As per the first variant.
    cumulativeProbs <-
      strategy |>
      dplyr::filter(N > 0L) |>
      dplyr::group_by(N) |>
      dplyr::group_split() |>
      purrr::accumulate(
        function (priorTurn, currentTurn) {
          priorTurn |>
            dplyr::select(
              -N,
              -PRIOR_TAKE
            ) |>
            dplyr::rename_with(
              stringr::str_replace,
              pattern = '^',
              replacement = 'PRIOR_'
            ) |>
            dplyr::left_join(
              currentTurn,
              by = 'PRIOR_TAKE',
              relationship = 'many-to-many'
            ) |>
            dplyr::filter(
              (PRIOR_TAKE & (!TAKE) & (PRIOR_D == D)) | !PRIOR_TAKE
            ) |>
            dplyr::mutate(
              VALUE =
                PRIOR_VALUE + dplyr::if_else(TAKE, D * 1.0, 0.0),
              PROB =
                dplyr::if_else(PRIOR_TAKE, PRIOR_PROB, PRIOR_PROB / Dmax)
            ) |>
            dplyr::count(
              N,
              D,
              VALUE,
              # Again, noting that the strategy depends on the previous action.
              PRIOR_TAKE,
              TAKE,
              wt = PROB,
              name = 'PROB'
            )
        },
        .init =
          tibble::tibble(
            N = 0L,
            D = seq.int(Dmax),
            VALUE = 0.0,
            PROB = 1.0 * (D == 1L)
          ) |>
          dplyr::left_join(
            strategy |>
              dplyr::select(N, D, PRIOR_TAKE, TAKE),
            by = c('N', 'D')
          )
      ) |>
      dplyr::bind_rows() |>
      dplyr::arrange(N, D, PRIOR_TAKE, TAKE)
    
    list(
      OUTCOMES = outcomes,
      STRATEGY = strategy,
      CUMULATIVE_PROBS = cumulativeProbs
    )
  }
