
library (ggplot2)


Dmax <- 20L
Nmax <- 100L


outcomes <-
  seq.int(from = Nmax - 1L, to = 1L) |>
  purrr::accumulate(
    function (prior, n) {
      toProcess <-
        tibble::tibble(
          D = seq.int(Dmax),
          N = n
        ) |>
        tidyr::expand_grid(
          TAKE = c(TRUE, FALSE)
        ) |>
        tidyr::expand_grid(
          prior |>
            dplyr::transmute(
              NEXT_D = D,
              NEXT_VALUE = VALUE,
              NEXT_TAKE = TAKE
            )
        ) |>
        dplyr::filter(
          (TAKE & (!NEXT_TAKE) & (D == NEXT_D))
           | !TAKE
        )
      
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
              NEXT_TAKE
            ) |>
            dplyr::summarise(
              VALUE = mean(NEXT_VALUE),
              .groups = 'drop_last'
            ) |>
            dplyr::summarise(
              VALUE = max(VALUE),
              .groups = 'drop'
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
    (N > 1L) | (D == 1L)
  ) |>
  dplyr::arrange(
    N,
    D
  )


strategy <-
  outcomes |>
  dplyr::filter(N > 1L) |>
  dplyr::group_by(N) |>
  dplyr::group_split() |>
  purrr::accumulate(
    function (prior, current) {
      prior |>
        dplyr::rename_with(
          stringr::str_replace,
          pattern = '^',
          replacement = 'PRIOR_'
        ) |>
        tidyr::expand_grid(
          current
        ) |>
        dplyr::filter(
          (PRIOR_TAKE & (!TAKE) & (PRIOR_D == D))
            | !PRIOR_TAKE
        ) |>
        dplyr::group_by(
          D
        ) |>
        dplyr::slice_max(order_by = VALUE, with_ties = FALSE) |>
        dplyr::ungroup() |>
        dplyr::select(
          N,
          D,
          TAKE,
          VALUE
        )
    },
    .init =
      outcomes |>
      dplyr::filter(N == 1L) |>
      dplyr::slice_max(order_by = VALUE)
  ) |>
  dplyr::bind_rows() |>
  dplyr::arrange(
    N,
    D
  )


cumulativeProbs <-
  strategy |>
  dplyr::filter(
    N > 1L
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
          TAKE,
          wt = PROB,
          name = 'PROB'
        )
    },
    .init =
      tibble::tibble(
        N = 1L,
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
  dplyr::bind_rows()


strategy |>
  ggplot(aes(x = N, y = D)) +
  geom_tile(aes(fill = TAKE), alpha = 0.75) +
  scale_x_continuous(
    name = 'Turn',
    expand = expansion()
  ) +
  scale_y_reverse(
    name = 'Dice Roll',
    n.breaks = Dmax,
    expand = expansion()
  ) +
  scale_fill_discrete(
    name = 'Strategy',
    labels = c(`TRUE` = 'Take', `FALSE` = 'Roll')
  ) +
  ggtitle(
    label = 'Recommended strategy by turn and dice roll.'
  ) +
  cowplot::theme_half_open() +
  cowplot::background_grid(major = 'y', minor = 'none', colour.major = 'black') +
  theme(
    legend.position = 'bottom'
  )


cumulativeProbs |>
  dplyr::slice_max(order_by = N) |>
  dplyr::count(
    VALUE,
    wt = PROB,
    name = 'PROB'
  ) |>
  ggplot(aes(x = VALUE, y = PROB)) +
  geom_col() +
  scale_x_continuous(
    name = 'Score'
  ) +
  scale_y_continuous(
    name = 'Probability'
  ) +
  ggtitle(
    label = 'Distribution of closing scores.'
  ) +
  cowplot::theme_half_open() +
  cowplot::background_grid()


cumulativeProbs |>
  dplyr::count(
    N,
    D,
    wt = PROB,
    name = 'PROB'
  ) |>
  ggplot(aes(x = N, y = PROB, group = D)) +
  geom_step(position = 'stack') +
  scale_x_continuous(
    name = 'Turn',
    expand = expansion()
  ) +
  scale_y_continuous(
    name = 'Dice Roll',
    expand = expansion()
  ) +
  ggtitle(
    label = 'Distribution of dice rolls by turn.'
  ) +
  cowplot::theme_half_open() +
  cowplot::background_grid()
