
fnPartIIIResults <-
  function (Dmax, Nmax) {
    outcomes <-
      # Note that we work back from the final turn.
      seq.int(from = Nmax - 1L, to = 0L) |>
      purrr::accumulate(
        function (nextTurn, n) {
          toProcess <-
            # Generate all combinations of actions and die value.
            tibble::tibble(
              D = seq.int(Dmax),
              N = n
            ) |>
            tidyr::expand_grid(
              TAKE = c(TRUE, FALSE),
              CASINO_ROLL = c(TRUE, FALSE)
            ) |>
            # Generate the Cartesian product of this with outcomes for
            # the next turn.
            tidyr::expand_grid(
              nextTurn |>
                dplyr::transmute(
                  NEXT_D = D,
                  NEXT_VALUE = VALUE
                )
            ) |>
            # If the player doesn't take the value, the casino cannot roll.
            # Otherwise, no need to filter by casino action.
            dplyr::filter(
              (!TAKE & !CASINO_ROLL) | TAKE
            ) |>
            # Prioritise TAKEs for when slicing.
            dplyr::arrange(N, D, !TAKE)
          
          toProcess |>
            # If we are taking, only consider those with the same die value
            # at the next turn provided the casino has NOT re-rolled.
            dplyr::filter(TAKE, !CASINO_ROLL, D == NEXT_D) |>
            # Consider the action for that next turn with the greatest
            # expected future pay-off.
            # This is where we assume that the player will always select
            # the approach that leads to the greatest expected future
            # pay-off; prioritising a take where there is a tie.
            dplyr::slice_max(order_by = NEXT_VALUE, with_ties = FALSE, by = D) |>
            # Add our current die value to this.
            dplyr::mutate(
              VALUE = D + NEXT_VALUE
            ) |>
            dplyr::select(
              N,
              D,
              TAKE,
              CASINO_ROLL,
              VALUE
            ) |>
            dplyr::bind_rows(
              toProcess |>
                # The following situations are equivalent:
                #  - Taking the money and the casino re-rolls.
                #  - Rolling the die (a prior filter ensures that the casino cannot roll)
                dplyr::filter(
                  (!TAKE) | (TAKE & CASINO_ROLL)
                ) |>
                dplyr::group_by(
                  N,
                  D,
                  TAKE,
                  CASINO_ROLL,
                  NEXT_D
                ) |>
                # Consider the action, for each die value, for that next
                # turn with the greatest expected future pay-off. 
                dplyr::summarise(
                  NEXT_VALUE = max(NEXT_VALUE),
                  .groups = 'drop_last'
                ) |>
                # Because we aren't taking, we are equally likely to hit
                # any die value for that next turn.
                dplyr::summarise(
                  VALUE = mean(NEXT_VALUE),
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
        (N > 0L) | (D == 1L)
      ) |>
      # Prioritise TAKEs.
      dplyr::arrange(N, D, !TAKE)
    
    
    strategy <-
      outcomes |>
      # We have to assume that the casino will always roll provided this
      # leads to a reduction in expected future pay-off.
      dplyr::slice_min(
        order_by = VALUE,
        by = c(N, D, TAKE),
        with_ties = FALSE
      ) |>
      # Beyond this, it is the same situation as per the first variant, where
      # the player chooses the action which maximised expected future pay-off,
      # allowing for the dastardly casino above.
      dplyr::slice_max(
        order_by = VALUE,
        by = c(N, D),
        with_ties = FALSE
      )
    
    
    cumulativeProbs <-
      strategy |>
      dplyr::filter(N > 0L) |>
      dplyr::group_by(N) |>
      dplyr::group_split() |>
      purrr::accumulate(
        function (priorTurn, currentTurn) {
          priorTurn |>
            dplyr::select(-N) |>
            dplyr::rename_with(
              stringr::str_replace,
              pattern = '^',
              replacement = 'PRIOR_'
            ) |>
            tidyr::expand_grid(
              currentTurn
            ) |>
            dplyr::filter(
              (PRIOR_TAKE & (!PRIOR_CASINO_ROLL) & (PRIOR_D == D))
                | (PRIOR_TAKE & PRIOR_CASINO_ROLL)
                | !PRIOR_TAKE
            ) |>
            dplyr::mutate(
              VALUE =
                PRIOR_VALUE + dplyr::if_else(TAKE, D * 1.0, 0.0),
              PROB =
                dplyr::case_when(
                  PRIOR_TAKE & !PRIOR_CASINO_ROLL ~ PRIOR_PROB,
                  PRIOR_TAKE ~ PRIOR_PROB / Dmax,
                  !PRIOR_TAKE ~ PRIOR_PROB / Dmax
                )
            ) |>
            # We only care about the total probability of achieving
            # any given combination of turn, die value and pay-off.
            dplyr::count(
              N,
              D,
              VALUE,
              TAKE,
              CASINO_ROLL,
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
              dplyr::select(N, D, TAKE, CASINO_ROLL),
            by = c('N', 'D')
          )
      ) |>
      dplyr::bind_rows() |>
      dplyr::select(
        -TAKE,
        -CASINO_ROLL
      )
    
    list(
      OUTCOMES = outcomes,
      STRATEGY = strategy,
      CUMULATIVE_PROBS = cumulativeProbs
    )
  }


fnPlotPartIIIRecommendedStrategy <-
  function (strategy) {
    strategy |>
      dplyr::mutate(
        STRATEGY =
          dplyr::case_when(
            TAKE & CASINO_ROLL ~ 'Take + Casino roll',
            TAKE ~ 'Take',
            !TAKE ~ 'Roll'
          )
      ) |>
      ggplot(aes(x = N, y = D)) +
      geom_tile(
        aes(fill = STRATEGY),
        alpha = 0.75
      ) +
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
        name = 'Strategy'
      ) +
      ggtitle(
        label =
          'Recommended strategy by turn and dice roll.'
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
