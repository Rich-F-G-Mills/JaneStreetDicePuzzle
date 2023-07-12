
fnPartIIResults <-
  function(Dmax, Nmax) {
    outcomes <-
      seq.int(from = Nmax - 1L, to = 0L) |>
      purrr::accumulate(
        function (nextTurn, n) {
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
            dplyr::filter(
              (TAKE & (!NEXT_TAKE) & (D == NEXT_D)) | !TAKE
            ) |>
            # Prioritise TAKEs.
            dplyr::arrange(N, D, !TAKE)
          
          toProcess |>
            dplyr::filter(TAKE) |>
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
    
    strategy <-
      outcomes |>
      dplyr::filter(N > 0L) |>
      dplyr::group_by(N) |>
      dplyr::group_split() |>
      purrr::accumulate(
        function (prior, current) {
          prior |>
            dplyr::transmute(
              PRIOR_D = D,
              PRIOR_TAKE = TAKE
            ) |>
            tidyr::expand_grid(
              current
            ) |>
            dplyr::filter(
              (PRIOR_TAKE & (!TAKE) & (PRIOR_D == D)) | !PRIOR_TAKE
            ) |>
            dplyr::arrange(
              N,
              D,
              # Prioritise TAKEs.
              !TAKE
            ) |>
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
    
    cumulativeProbs <-
      strategy |>
      dplyr::filter(N > 0L) |>
      dplyr::group_by(N) |>
      dplyr::group_split() |>
      purrr::accumulate(
        function (prior, current) {
          prior |>
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
              current,
              by = 'PRIOR_TAKE',
              relationship = 'many-to-many'
            ) |>
            dplyr::filter(
              (PRIOR_TAKE & (!TAKE) & (PRIOR_D == D)) | !PRIOR_TAKE
            ) |>
            dplyr::mutate(
              VALUE = PRIOR_VALUE + dplyr::if_else(TAKE, D * 1.0, 0.0),
              PROB = dplyr::if_else(PRIOR_TAKE, PRIOR_PROB, PRIOR_PROB / Dmax)
            ) |>
            dplyr::count(
              N,
              D,
              VALUE,
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
