
fnPlotRecommendedStrategy <-
  function (strategy) {
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
  }


fnPlotDistributionClosingScores <-
  function (cumulativeProbs) {
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
  }


fnPlotDistributionByTurn <-
  function (cumulativeProbs) {
    cumulativeProbs |>
      dplyr::filter(
        N > 0L | D == 1L
      ) |>
      dplyr::count(
        N,
        D,
        wt = PROB,
        name = 'PROB'
      ) |>
      ggplot(aes(x = N, y = PROB, group = D)) +
      geom_line(position = 'stack') +
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
  }
