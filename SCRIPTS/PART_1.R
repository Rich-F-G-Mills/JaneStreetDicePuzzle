
fnPartIResults <-
  function (Dmax, Nmax) {
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
              (TAKE & (D == NEXT_D)) | !TAKE
            ) |>
            # Prioritise TAKEs.
            dplyr::arrange(N, D, !TAKE)
          
          toProcess |>
            dplyr::filter(TAKE) |>
            dplyr::slice_max(order_by = NEXT_VALUE, with_ties = FALSE, by = D) |>
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
      dplyr::slice_max(order_by = VALUE, by = c(N, D))
    
    cumulativeProbs <-
      strategy |>
      dplyr::filter(
        N > 0L
      ) |>
      dplyr::group_by(N) |>
      dplyr::group_split() |>
      purrr::accumulate(
        function (prior, current) {
          prior |>
            dplyr::select(
              -N
            ) |>
            dplyr::rename_with(
              stringr::str_replace,
              pattern = '^',
              replacement = 'PRIOR_'
            ) |>
            tidyr::expand_grid(
              current
            ) |>
            dplyr::filter(
              (PRIOR_TAKE & (PRIOR_D == D)) | !PRIOR_TAKE
            ) |>
            dplyr::mutate(
              VALUE = PRIOR_VALUE + dplyr::if_else(TAKE, D * 1.0, 0.0),
              PROB = dplyr::if_else(PRIOR_TAKE, PRIOR_PROB, PRIOR_PROB / Dmax)
            ) |>
            dplyr::count(
              N,
              D,
              VALUE,
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
              dplyr::select(N, D, TAKE),
            by = c('N', 'D')
          )
      ) |>
      dplyr::bind_rows() |>
      dplyr::select(
        -TAKE
      )
    
    list(
      OUTCOMES = outcomes,
      STRATEGY = strategy,
      CUMULATIVE_PROBS = cumulativeProbs
    )
  }


