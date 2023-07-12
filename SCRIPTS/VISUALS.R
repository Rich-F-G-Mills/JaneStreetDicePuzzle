
fnPlotRecommendedStrategy <-
  function (strategy, title = NULL) {
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
        label =
          title %||% 'Recommended strategy by turn and dice roll.'
      ) +
      cowplot::theme_half_open() +
      cowplot::background_grid(
        major = 'y',
        minor = 'none',
        colour.major = 'black'
      ) +
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
        name = 'Score',
        labels = scales::label_comma()
      ) +
      scale_y_continuous(
        name = 'Probability',
        labels = scales::label_percent(accuracy = 0.1)
      ) +
      ggtitle(
        label = 'Distribution of closing scores.'
      ) +
      cowplot::theme_half_open() +
      cowplot::background_grid()
  }


fnPlotDistributionByTurn <-
  function (cumulativeProbs) {
    probsByTurn <-
      cumulativeProbs |>
      dplyr::filter(
        N > 0L
      ) |>
      dplyr::count(
        N,
        D,
        wt = PROB,
        name = 'PROB'
      )
    
    significantRolls <-
      probsByTurn |>
      dplyr::slice_max(order_by = N) |>
      dplyr::arrange(-D) |>
      dplyr::mutate(
        CUMUL_PROB = cumsum(PROB)
      ) |>
      dplyr::filter(
        PROB > 0.10
      )
    
    probsByTurn |>
      ggplot(aes(x = N, y = PROB, group = D)) +
      geom_line(
        position = 'stack',
        color = 'black'
      ) +
      geom_text(
        data = significantRolls,
        aes(y = CUMUL_PROB, label = glue::glue('P(Die value is {D} after turn {Nmax}) = {scales::percent(PROB)}')),
        hjust = 1.0,
        nudge_x = -2.5,
        nudge_y = -0.025
      ) +
      scale_x_continuous(
        name = 'Turn',
        expand = expansion()
      ) +
      scale_y_continuous(
        name = 'Cumulative Probability',
        expand = expansion(),
        labels = scales::label_percent(accuracy = 1.0)
      ) +
      ggtitle(
        label = 'Distribution of dice rolls by turn.'
      ) +
      cowplot::theme_half_open() +
      cowplot::background_grid()
  }
