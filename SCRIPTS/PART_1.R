
fnPartIResults <-
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
              TAKE = c(TRUE, FALSE)
            ) |>
            # Generate the cartesian product of this with outcomes for
            # the next turn.
            tidyr::expand_grid(
              nextTurn |>
                dplyr::transmute(
                  NEXT_D = D,
                  NEXT_VALUE = VALUE,
                  NEXT_TAKE = TAKE
                )
            ) |>
            # Prioritise TAKEs for when slicing.
            dplyr::arrange(N, D, !TAKE)
          
          toProcess |>
            # If we are taking, only consider those with the same die value
            # at the next turn.
            dplyr::filter(TAKE, D == NEXT_D) |>
            # Consider the action for that next turn with the greatest
            # expected future pay-off.
            # This is where we assume that the player will always select
            # the approach that leads to the greatest expected future
            # pay-off; prioritsing a take where there is a tie.
            dplyr::slice_max(order_by = NEXT_VALUE, with_ties = FALSE, by = D) |>
            # Add our current die value to this.
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
                # If we are NOT taking, we don't restrict die values
                # for the next turn.
                dplyr::filter(!TAKE) |>
                dplyr::group_by(
                  N,
                  D,
                  TAKE,
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
    
    # The optimal strategy is taken to be, for each die value 
    # and turn, that which has the greatest expected future pay-off.
    strategy <-
      outcomes |>
      dplyr::slice_max(order_by = VALUE, by = c(N, D))
    
    # This time working from the initial game state.
    # We build up the accrued "banked" values and probabilities
    # as we move along the turns.
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
              (PRIOR_TAKE & (PRIOR_D == D)) | !PRIOR_TAKE
            ) |>
            dplyr::mutate(
              VALUE =
                PRIOR_VALUE + dplyr::if_else(TAKE, D * 1.0, 0.0),
              PROB =
                dplyr::if_else(PRIOR_TAKE, PRIOR_PROB, PRIOR_PROB / Dmax)
            ) |>
            # We only care about the total probability of achieving
            # any given combination of turn, die value and pay-off.
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


