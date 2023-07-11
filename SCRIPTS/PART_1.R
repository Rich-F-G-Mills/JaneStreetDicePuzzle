
fnPartIResults <-
  function (Dmax, Nmax) {
    strategy <-
      seq.int(from = Nmax - 1L, to = 0L) |>
      purrr::accumulate(
        function (prior, n) {
          tibble::tibble(
            D = seq.int(Dmax),
            N = n
          ) |>
          dplyr::left_join(
            prior |>
              dplyr::transmute(
                D,
                NEXT_VALUE = VALUE
              ),
            by = 'D'
          ) |>
          dplyr::transmute(
            N,
            D,
            VALUE_TAKE = D + NEXT_VALUE,
            VALUE_ROLL = mean(NEXT_VALUE),
            VALUE = pmax(VALUE_TAKE, VALUE_ROLL),
            TAKE = VALUE_TAKE >= VALUE_ROLL
          )
        },
        .init =
          tibble::tibble(
            N = Nmax,
            D = seq.int(Dmax),
            VALUE_TAKE = D,
            VALUE_ROLL = 0.0,
            VALUE = VALUE_TAKE,
            TAKE = TRUE
          )
      ) |>
      dplyr::bind_rows() |>
      dplyr::filter(
        (N > 0L) | (D == 1L)
      ) |>
      dplyr::arrange(
        N,
        D
      )
    
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
      STRATEGY = strategy,
      CUMULATIVE_PROBS = cumulativeProbs
    )
  }
