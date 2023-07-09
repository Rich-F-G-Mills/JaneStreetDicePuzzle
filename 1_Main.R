
library (ggplot2)
library (magrittr)


Dmax <- 20L
Nmax <- 100L


strategy <-
  purrr::accumulate(
    seq.int(from = Nmax - 1L, to = 1L),
    function (prior, n) {
      tibble::tibble(
        D = seq.int(Dmax),
        N = n
      ) %>%
      dplyr::left_join(
        prior %>%
          dplyr::transmute(
            D,
            NEXT_VALUE = VALUE
          ),
        by = 'D'
      ) %>%
      dplyr::mutate(
        VALUE_TAKE = D + NEXT_VALUE,
        VALUE_ROLL = mean(NEXT_VALUE),
        TAKE = VALUE_TAKE >= VALUE_ROLL,
        VALUE = pmax(VALUE_TAKE, VALUE_ROLL)
      ) %>%
      dplyr::select(
        N,
        D,
        VALUE,
        TAKE
      )
    },
    .init =
      tibble::tibble(
        N = Nmax,
        D = seq.int(Dmax),
        VALUE = D,
        TAKE = TRUE
      )
  ) %>%
  dplyr::bind_rows() %>%
  dplyr::filter(
    (N > 1L) | (D == 1L)
  ) %>%
  dplyr::arrange(
    N,
    D
  )


cumulativeProbs <-
  strategy %>%
  dplyr::filter(
    N > 1L
  ) %>%
  dplyr::group_by(N) %>%
  dplyr::group_split() %>%
  purrr::accumulate(
    function (prior, current) {
      prior %>%
        dplyr::select(
          -N
        ) %>%
        dplyr::rename_with(
          stringr::str_replace,
          pattern = '^',
          replacement = 'PRIOR_'
        ) %>%
        tidyr::expand_grid(
          current
        ) %>%
        dplyr::filter(
          (PRIOR_TAKE & (PRIOR_D == D)) | !PRIOR_TAKE
        ) %>%
        dplyr::mutate(
          VALUE = PRIOR_VALUE + dplyr::if_else(TAKE, D * 1.0, 0.0),
          PROB = dplyr::if_else(PRIOR_TAKE, PRIOR_PROB, PRIOR_PROB / Dmax)
        ) %>%
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
        D = 1L,
        VALUE = 0,
        PROB = 1.0
      ) %>%
      dplyr::left_join(
        strategy %>%
          dplyr::select(N, D, TAKE),
        by = c('N', 'D')
      )
  ) %>%
  dplyr::bind_rows()


strategy %>%
  ggplot(aes(x = N, y = D)) +
  geom_tile(aes(fill = TAKE), alpha = 0.75) +
  scale_x_continuous(
    expand = expansion()
  ) +
  scale_y_reverse(
    n.breaks = Dmax,
    expand = expansion()
  ) +
  scale_fill_discrete(
    name = 'Strategy',
    labels = c(`TRUE` = 'Take', `FALSE` = 'Roll')
  ) +
  cowplot::theme_half_open() +
  cowplot::background_grid(major = 'y', minor = 'none', colour.major = 'black') +
  theme(
    legend.position = 'bottom'
  )


cumulativeProbs %>%
  dplyr::count(
    N,
    D,
    wt = PROB,
    name = 'PROB'
  ) %>%
  ggplot(aes(x = N, y = D)) +
  geom_tile(aes(fill = PROB), alpha = 0.75) +
  scale_x_continuous(
    expand = expansion()
  ) +
  scale_y_reverse(
    n.breaks = Dmax,
    expand = expansion()
  ) +
  scale_fill_gradient(
    low = 'black',
    high = 'orange'
  ) +
  cowplot::theme_half_open() +
  cowplot::background_grid(major = 'y', minor = 'none', colour.major = 'black') +
  theme(
    legend.position = 'bottom',
    legend.key.width = unit(2, 'cm')
  )


cumulativeProbs %>%
  dplyr::slice_max(order_by = N) %>%
  dplyr::count(
    VALUE,
    wt = PROB,
    name = 'PROB'
  ) %>%
  ggplot(aes(x = VALUE, y = PROB)) +
  geom_col()
