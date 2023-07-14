---
title: "Jane Street Dice Puzzle"
output: 
  html_document: 
    toc: yes
    toc_float:
      smooth_scroll: yes
    pandoc_args: "--lua-filter=ASSETS/colour-text.lua"
    keep_md: yes
author: "Richard Mills"
date: "2023-07-14"
---











<style type="text/css">
h2 {
  margin-top: 30px;
  text-decoration: underline;
}

p:has(+ ul) {
  margin-bottom: 0;
}
  
#TOC > ul > li {
  font-weight: bold
}
</style>

## Introduction

The purpose of this note is to show proposed solutions to all three Jane Street dice puzzles proposed within the following [YouTube video](https://www.youtube.com/watch?v=NT_I1MjckaU&t=251s).

## First Variant

The following rules apply:

* There is a 20-sided die.
* There are 100 turns.
* At each turn, the player can choose to either:
    * "Take" (ie. bank) the value as currently shown on the die.
    * Re-roll the dice without any pay-off.
* The die initially shows a value of 1.

For example, the player could (unwisely) elect to repeatedly take the opening value of 1 for all 100 turns, giving a final banked value of 100.

### Possible Solution (Toy Example)

As a simplified toy example, instead assume we have a 4-sided die over 6 turns.

* Each node (ie. circle) represents a decision-point.
* When determining the optimal strategy, the **expected future gain** for each of take and roll is considered; "taking" the value is considered the preferable strategy where this expected pay-off, considering all remaining turns, is at least as great as that for a roll.
* Those with a [**red**]{foreground="red"} and [**blue**]{foreground="blue"} outline reflect those nodes where the optimal decision is to roll and take respectively.
* The expected future gain from such a decision is shown by the top and bottom numbers within each node.
* The extent of the [**fill**]{background="lightblue"} within each node shows the probability of the player reaching that node, within a given turn.
* For those nodes where the player should <u>**take**</u> the current die value, that value is maintained for the next turn as represented by the **thick black** horizontal lines. We note that all such nodes are absorbing states.
* Whereas, for those where the player should <u>**roll**</u>, there is an equal chance of landing on any die value for the next turn.
* At any given node, it is assumed that the player will always take the action that leads to the largest expected future pay-off, irrespective of what has happened before.


```{=html}
<svg viewbox="0 0 600 315">
<style>circle {stroke-width:2px;fill:white;} text {text-anchor:middle;alignment-baseline:middle;}</style>
<rect x="50" y="78" width="550" height="44" fill="#f0e1f7"></rect>
<rect x="50" y="133" width="550" height="44" fill="#f0e1f7"></rect>
<rect x="50" y="188" width="550" height="44" fill="#f0e1f7"></rect>
<rect x="50" y="243" width="550" height="44" fill="#f0e1f7"></rect>
<line x1="100" x2="100" y1="60" y2="100" stroke-dasharray="2 2" stroke="black"></line>
<line x1="175" x2="175" y1="60" y2="100" stroke-dasharray="2 2" stroke="black"></line>
<line x1="250" x2="250" y1="60" y2="100" stroke-dasharray="2 2" stroke="black"></line>
<line x1="325" x2="325" y1="60" y2="100" stroke-dasharray="2 2" stroke="black"></line>
<line x1="400" x2="400" y1="60" y2="100" stroke-dasharray="2 2" stroke="black"></line>
<line x1="475" x2="475" y1="60" y2="100" stroke-dasharray="2 2" stroke="black"></line>
<line x1="550" x2="550" y1="60" y2="100" stroke-dasharray="2 2" stroke="black"></line>
<line x1="100" x2="175" y1="100" y2="100" stroke="grey" stroke-width="1px"></line>
<line x1="100" x2="175" y1="100" y2="155" stroke="grey" stroke-width="1px"></line>
<line x1="100" x2="175" y1="100" y2="210" stroke="grey" stroke-width="1px"></line>
<line x1="100" x2="175" y1="100" y2="265" stroke="grey" stroke-width="1px"></line>
<line x1="175" x2="250" y1="100" y2="100" stroke="grey" stroke-width="1px"></line>
<line x1="175" x2="250" y1="100" y2="155" stroke="grey" stroke-width="1px"></line>
<line x1="175" x2="250" y1="100" y2="210" stroke="grey" stroke-width="1px"></line>
<line x1="175" x2="250" y1="100" y2="265" stroke="grey" stroke-width="1px"></line>
<line x1="175" x2="250" y1="155" y2="100" stroke="grey" stroke-width="1px"></line>
<line x1="175" x2="250" y1="155" y2="155" stroke="grey" stroke-width="1px"></line>
<line x1="175" x2="250" y1="155" y2="210" stroke="grey" stroke-width="1px"></line>
<line x1="175" x2="250" y1="155" y2="265" stroke="grey" stroke-width="1px"></line>
<line x1="175" x2="250" y1="210" y2="210" stroke="black" stroke-width="3px"></line>
<line x1="175" x2="250" y1="265" y2="265" stroke="black" stroke-width="3px"></line>
<line x1="250" x2="325" y1="100" y2="100" stroke="grey" stroke-width="1px"></line>
<line x1="250" x2="325" y1="100" y2="155" stroke="grey" stroke-width="1px"></line>
<line x1="250" x2="325" y1="100" y2="210" stroke="grey" stroke-width="1px"></line>
<line x1="250" x2="325" y1="100" y2="265" stroke="grey" stroke-width="1px"></line>
<line x1="250" x2="325" y1="155" y2="100" stroke="grey" stroke-width="1px"></line>
<line x1="250" x2="325" y1="155" y2="155" stroke="grey" stroke-width="1px"></line>
<line x1="250" x2="325" y1="155" y2="210" stroke="grey" stroke-width="1px"></line>
<line x1="250" x2="325" y1="155" y2="265" stroke="grey" stroke-width="1px"></line>
<line x1="250" x2="325" y1="210" y2="210" stroke="black" stroke-width="3px"></line>
<line x1="250" x2="325" y1="265" y2="265" stroke="black" stroke-width="3px"></line>
<line x1="325" x2="400" y1="100" y2="100" stroke="grey" stroke-width="1px"></line>
<line x1="325" x2="400" y1="100" y2="155" stroke="grey" stroke-width="1px"></line>
<line x1="325" x2="400" y1="100" y2="210" stroke="grey" stroke-width="1px"></line>
<line x1="325" x2="400" y1="100" y2="265" stroke="grey" stroke-width="1px"></line>
<line x1="325" x2="400" y1="155" y2="100" stroke="grey" stroke-width="1px"></line>
<line x1="325" x2="400" y1="155" y2="155" stroke="grey" stroke-width="1px"></line>
<line x1="325" x2="400" y1="155" y2="210" stroke="grey" stroke-width="1px"></line>
<line x1="325" x2="400" y1="155" y2="265" stroke="grey" stroke-width="1px"></line>
<line x1="325" x2="400" y1="210" y2="210" stroke="black" stroke-width="3px"></line>
<line x1="325" x2="400" y1="265" y2="265" stroke="black" stroke-width="3px"></line>
<line x1="400" x2="475" y1="100" y2="100" stroke="grey" stroke-width="1px"></line>
<line x1="400" x2="475" y1="100" y2="155" stroke="grey" stroke-width="1px"></line>
<line x1="400" x2="475" y1="100" y2="210" stroke="grey" stroke-width="1px"></line>
<line x1="400" x2="475" y1="100" y2="265" stroke="grey" stroke-width="1px"></line>
<line x1="400" x2="475" y1="155" y2="155" stroke="black" stroke-width="3px"></line>
<line x1="400" x2="475" y1="210" y2="210" stroke="black" stroke-width="3px"></line>
<line x1="400" x2="475" y1="265" y2="265" stroke="black" stroke-width="3px"></line>
<line x1="475" x2="550" y1="100" y2="100" stroke="grey" stroke-width="1px"></line>
<line x1="475" x2="550" y1="100" y2="155" stroke="grey" stroke-width="1px"></line>
<line x1="475" x2="550" y1="100" y2="210" stroke="grey" stroke-width="1px"></line>
<line x1="475" x2="550" y1="100" y2="265" stroke="grey" stroke-width="1px"></line>
<line x1="475" x2="550" y1="155" y2="155" stroke="black" stroke-width="3px"></line>
<line x1="475" x2="550" y1="210" y2="210" stroke="black" stroke-width="3px"></line>
<line x1="475" x2="550" y1="265" y2="265" stroke="black" stroke-width="3px"></line>
<circle cx="100" cy="100" r="17" stroke="red"></circle>
<circle cx="175" cy="100" r="17" stroke="red"></circle>
<circle cx="175" cy="155" r="17" stroke="red"></circle>
<circle cx="175" cy="210" r="17" stroke="blue"></circle>
<circle cx="175" cy="265" r="17" stroke="blue"></circle>
<circle cx="250" cy="100" r="17" stroke="red"></circle>
<circle cx="250" cy="155" r="17" stroke="red"></circle>
<circle cx="250" cy="210" r="17" stroke="blue"></circle>
<circle cx="250" cy="265" r="17" stroke="blue"></circle>
<circle cx="325" cy="100" r="17" stroke="red"></circle>
<circle cx="325" cy="155" r="17" stroke="red"></circle>
<circle cx="325" cy="210" r="17" stroke="blue"></circle>
<circle cx="325" cy="265" r="17" stroke="blue"></circle>
<circle cx="400" cy="100" r="17" stroke="red"></circle>
<circle cx="400" cy="155" r="17" stroke="blue"></circle>
<circle cx="400" cy="210" r="17" stroke="blue"></circle>
<circle cx="400" cy="265" r="17" stroke="blue"></circle>
<circle cx="475" cy="100" r="17" stroke="red"></circle>
<circle cx="475" cy="155" r="17" stroke="blue"></circle>
<circle cx="475" cy="210" r="17" stroke="blue"></circle>
<circle cx="475" cy="265" r="17" stroke="blue"></circle>
<circle cx="550" cy="100" r="17" stroke="blue"></circle>
<circle cx="550" cy="155" r="17" stroke="blue"></circle>
<circle cx="550" cy="210" r="17" stroke="blue"></circle>
<circle cx="550" cy="265" r="17" stroke="blue"></circle>
<rect x="84" y="84" width="32" height="32" fill="lightblue" clip-path="circle(16px at 50% 16px)"></rect>
<rect x="159" y="108" width="32" height="8" fill="lightblue" clip-path="circle(16px at 50% -8px)"></rect>
<rect x="159" y="163" width="32" height="8" fill="lightblue" clip-path="circle(16px at 50% -8px)"></rect>
<rect x="159" y="218" width="32" height="8" fill="lightblue" clip-path="circle(16px at 50% -8px)"></rect>
<rect x="159" y="273" width="32" height="8" fill="lightblue" clip-path="circle(16px at 50% -8px)"></rect>
<rect x="234" y="112" width="32" height="4" fill="lightblue" clip-path="circle(16px at 50% -12px)"></rect>
<rect x="234" y="167" width="32" height="4" fill="lightblue" clip-path="circle(16px at 50% -12px)"></rect>
<rect x="234" y="214" width="32" height="12" fill="lightblue" clip-path="circle(16px at 50% -4px)"></rect>
<rect x="234" y="269" width="32" height="12" fill="lightblue" clip-path="circle(16px at 50% -4px)"></rect>
<rect x="309" y="114" width="32" height="2" fill="lightblue" clip-path="circle(16px at 50% -14px)"></rect>
<rect x="309" y="169" width="32" height="2" fill="lightblue" clip-path="circle(16px at 50% -14px)"></rect>
<rect x="309" y="212" width="32" height="14" fill="lightblue" clip-path="circle(16px at 50% -2px)"></rect>
<rect x="309" y="267" width="32" height="14" fill="lightblue" clip-path="circle(16px at 50% -2px)"></rect>
<rect x="384" y="115" width="32" height="1" fill="lightblue" clip-path="circle(16px at 50% -15px)"></rect>
<rect x="384" y="170" width="32" height="1" fill="lightblue" clip-path="circle(16px at 50% -15px)"></rect>
<rect x="384" y="211" width="32" height="15" fill="lightblue" clip-path="circle(16px at 50% -1px)"></rect>
<rect x="384" y="266" width="32" height="15" fill="lightblue" clip-path="circle(16px at 50% -1px)"></rect>
<rect x="459" y="115.75" width="32" height="0.25" fill="lightblue" clip-path="circle(16px at 50% -15.75px)"></rect>
<rect x="459" y="169.75" width="32" height="1.25" fill="lightblue" clip-path="circle(16px at 50% -14.75px)"></rect>
<rect x="459" y="210.75" width="32" height="15.25" fill="lightblue" clip-path="circle(16px at 50% -0.75px)"></rect>
<rect x="459" y="265.75" width="32" height="15.25" fill="lightblue" clip-path="circle(16px at 50% -0.75px)"></rect>
<rect x="534" y="115.9375" width="32" height="0.0625" fill="lightblue" clip-path="circle(16px at 50% -15.9375px)"></rect>
<rect x="534" y="169.6875" width="32" height="1.3125" fill="lightblue" clip-path="circle(16px at 50% -14.6875px)"></rect>
<rect x="534" y="210.6875" width="32" height="15.3125" fill="lightblue" clip-path="circle(16px at 50% -0.6875px)"></rect>
<rect x="534" y="265.6875" width="32" height="15.3125" fill="lightblue" clip-path="circle(16px at 50% -0.6875px)"></rect>
<text font-size="75%" x="100" y="92.5">17.6</text>
<text font-size="75%" x="175" y="92.5">14.3</text>
<text font-size="75%" x="175" y="147.5">14.3</text>
<text font-size="75%" x="175" y="202.5">14.3</text>
<text font-size="75%" x="175" y="257.5">14.3</text>
<text font-size="75%" x="250" y="92.5">11.0</text>
<text font-size="75%" x="250" y="147.5">11.0</text>
<text font-size="75%" x="250" y="202.5">11.0</text>
<text font-size="75%" x="250" y="257.5">11.0</text>
<text font-size="75%" x="325" y="92.5">8.0</text>
<text font-size="75%" x="325" y="147.5">8.0</text>
<text font-size="75%" x="325" y="202.5">8.0</text>
<text font-size="75%" x="325" y="257.5">8.0</text>
<text font-size="75%" x="400" y="92.5">5.1</text>
<text font-size="75%" x="400" y="147.5">5.1</text>
<text font-size="75%" x="400" y="202.5">5.1</text>
<text font-size="75%" x="400" y="257.5">5.1</text>
<text font-size="75%" x="475" y="92.5">2.5</text>
<text font-size="75%" x="475" y="147.5">2.5</text>
<text font-size="75%" x="475" y="202.5">2.5</text>
<text font-size="75%" x="475" y="257.5">2.5</text>
<text font-size="75%" x="550" y="92.5">0.0</text>
<text font-size="75%" x="550" y="147.5">0.0</text>
<text font-size="75%" x="550" y="202.5">0.0</text>
<text font-size="75%" x="550" y="257.5">0.0</text>
<text font-size="75%" x="100" y="107.5">15.3</text>
<text font-size="75%" x="175" y="107.5">12.0</text>
<text font-size="75%" x="175" y="162.5">13.0</text>
<text font-size="75%" x="175" y="217.5">18.0</text>
<text font-size="75%" x="175" y="272.5">24.0</text>
<text font-size="75%" x="250" y="107.5">9.0</text>
<text font-size="75%" x="250" y="162.5">10.0</text>
<text font-size="75%" x="250" y="217.5">15.0</text>
<text font-size="75%" x="250" y="272.5">20.0</text>
<text font-size="75%" x="325" y="107.5">6.1</text>
<text font-size="75%" x="325" y="162.5">8.0</text>
<text font-size="75%" x="325" y="217.5">12.0</text>
<text font-size="75%" x="325" y="272.5">16.0</text>
<text font-size="75%" x="400" y="107.5">3.5</text>
<text font-size="75%" x="400" y="162.5">6.0</text>
<text font-size="75%" x="400" y="217.5">9.0</text>
<text font-size="75%" x="400" y="272.5">12.0</text>
<text font-size="75%" x="475" y="107.5">2.0</text>
<text font-size="75%" x="475" y="162.5">4.0</text>
<text font-size="75%" x="475" y="217.5">6.0</text>
<text font-size="75%" x="475" y="272.5">8.0</text>
<text font-size="75%" x="550" y="107.5">1.0</text>
<text font-size="75%" x="550" y="162.5">2.0</text>
<text font-size="75%" x="550" y="217.5">3.0</text>
<text font-size="75%" x="550" y="272.5">4.0</text>
<text x="65" y="100">1</text>
<text x="65" y="155">2</text>
<text x="65" y="210">3</text>
<text x="65" y="265">4</text>
<text x="100" y="50">START</text>
<text x="175" y="50">1</text>
<text x="250" y="50">2</text>
<text x="325" y="50">3</text>
<text x="400" y="50">4</text>
<text x="475" y="50">5</text>
<text x="550" y="50">6</text>
<text font-weight="bold" transform="translate(25, 182.5) rotate(-90)">DICE ROLL</text>
<text x="325" y="25" font-weight="bold">TURN</text>
</svg>
```

We are now ready to consider the full puzzle specification.

### Proposed Solution (Original Puzzle) {.tabset}



Here we consider the 20 sided die across 100 turns.

Due to the number of decision points, we cannot use the same layout as for the toy example above.

However, we can still use the same underlying approach to identify the recommended strategy.

<br/>

#### Strategy

* When the game starts, the player should always roll.
* Should the die show any value on/above 18, the player is recommended to continually take that value for all remaining turns.
* This also becomes the case for lower die values, once the game progresses.
* These dice rolls effectively become **absorbing states**, albeit after a varying number of elapsed turns.
* For the last turn, as expected, the player is recommended to take the value regardless as there is no benefit from rolling.

![](SUMMARY_files/figure-html/unnamed-chunk-3-1.png)<!-- -->

#### Visits

* This clearly highlights that, as turns progress, we are attracted to dice rolls 18, 19 and 20.
* This is because, once those values are obtained, the strategy dictates that we will repeatedly take those values, with<u>out</u> any rolls.
* Consequently, assuming the strategy is followed, the probability of all other dice rolls approaches zero.

![](SUMMARY_files/figure-html/unnamed-chunk-4-1.png)<!-- -->

#### Outcomes



* The maximum possible score is 20 x 100 = 2,000.
* As a consequence of the strategy, we see that some values are more likely than others; we would expect the more significant spikes to be "near" multiples of 18, 19 and 20; that is, some of the "lumpiness" is likely a consequence of those absorbing states.
* The expected closing score, using the proposed strategy, is 1,792.3, as indicated by the vertical [red]{foreground="red"} line.

![](SUMMARY_files/figure-html/unnamed-chunk-6-1.png)<!-- -->

## Second Variant

The rules are as for the first variant above, but with the following differences:

* Any time the player chooses to take (ie. bank) the current value, the next turn (assuming there are turns remaining), **must** be a roll of the die.
* Unlike the decision to bank, there is no limit to consecutive rolls.

For example, the player could roll, bank, roll, roll, bank, etc...

### Proposed Solution (Toy Example)

Revisiting the same toy example as before, we now observe the following.

* Note that the layout is different as the available action at a given node depends on what action was taken for the <u>previous</u> turn; specifically, the rules specify that if a value was taken during the previous turn, the player **must** roll for the current turn.
* For nodes where a roll is taken ([**red**]{foreground="red"} outline), lines connect to the roll/take nodes for the next turn which have the highest expected value for each respective dice roll.
* For nodes where the value is taken ([**blue**]{foreground="blue"} outline), the node is directly linked (via a diagonal **thick black** line) to the corresponding roll for that same die value at the next turn.


```{=html}
<svg viewbox="0 0 900 490">
<style>circle {stroke-width:2px;fill:white;} text {text-anchor:middle;alignment-baseline:middle;}</style>
<rect x="50" y="78" width="850" height="84" fill="#f0e1f7"></rect>
<rect x="50" y="178" width="850" height="84" fill="#f0e1f7"></rect>
<rect x="50" y="278" width="850" height="84" fill="#f0e1f7"></rect>
<rect x="50" y="378" width="850" height="84" fill="#f0e1f7"></rect>
<line x1="100" x2="100" y1="60" y2="100" stroke-dasharray="2 2" stroke="black"></line>
<line x1="225" x2="225" y1="60" y2="100" stroke-dasharray="2 2" stroke="black"></line>
<line x1="350" x2="350" y1="60" y2="100" stroke-dasharray="2 2" stroke="black"></line>
<line x1="475" x2="475" y1="60" y2="100" stroke-dasharray="2 2" stroke="black"></line>
<line x1="600" x2="600" y1="60" y2="100" stroke-dasharray="2 2" stroke="black"></line>
<line x1="725" x2="725" y1="60" y2="100" stroke-dasharray="2 2" stroke="black"></line>
<line x1="850" x2="850" y1="60" y2="100" stroke-dasharray="2 2" stroke="black"></line>
<line x1="100" x2="225" y1="140" y2="100" stroke="black" stroke-width="3px"></line>
<line x1="100" x2="225" y1="100" y2="100" stroke="grey" stroke-width="1px"></line>
<line x1="100" x2="225" y1="100" y2="240" stroke="grey" stroke-width="1px"></line>
<line x1="100" x2="225" y1="100" y2="340" stroke="grey" stroke-width="1px"></line>
<line x1="100" x2="225" y1="100" y2="440" stroke="grey" stroke-width="1px"></line>
<line x1="225" x2="350" y1="140" y2="100" stroke="black" stroke-width="3px"></line>
<line x1="225" x2="350" y1="100" y2="140" stroke="grey" stroke-width="1px"></line>
<line x1="225" x2="350" y1="100" y2="240" stroke="grey" stroke-width="1px"></line>
<line x1="225" x2="350" y1="100" y2="340" stroke="grey" stroke-width="1px"></line>
<line x1="225" x2="350" y1="100" y2="440" stroke="grey" stroke-width="1px"></line>
<line x1="225" x2="350" y1="240" y2="200" stroke="black" stroke-width="3px"></line>
<line x1="225" x2="350" y1="200" y2="140" stroke="grey" stroke-width="1px"></line>
<line x1="225" x2="350" y1="200" y2="240" stroke="grey" stroke-width="1px"></line>
<line x1="225" x2="350" y1="200" y2="340" stroke="grey" stroke-width="1px"></line>
<line x1="225" x2="350" y1="200" y2="440" stroke="grey" stroke-width="1px"></line>
<line x1="225" x2="350" y1="340" y2="300" stroke="black" stroke-width="3px"></line>
<line x1="225" x2="350" y1="300" y2="140" stroke="grey" stroke-width="1px"></line>
<line x1="225" x2="350" y1="300" y2="240" stroke="grey" stroke-width="1px"></line>
<line x1="225" x2="350" y1="300" y2="340" stroke="grey" stroke-width="1px"></line>
<line x1="225" x2="350" y1="300" y2="440" stroke="grey" stroke-width="1px"></line>
<line x1="225" x2="350" y1="440" y2="400" stroke="black" stroke-width="3px"></line>
<line x1="225" x2="350" y1="400" y2="140" stroke="grey" stroke-width="1px"></line>
<line x1="225" x2="350" y1="400" y2="240" stroke="grey" stroke-width="1px"></line>
<line x1="225" x2="350" y1="400" y2="340" stroke="grey" stroke-width="1px"></line>
<line x1="225" x2="350" y1="400" y2="440" stroke="grey" stroke-width="1px"></line>
<line x1="350" x2="475" y1="140" y2="100" stroke="black" stroke-width="3px"></line>
<line x1="350" x2="475" y1="100" y2="100" stroke="grey" stroke-width="1px"></line>
<line x1="350" x2="475" y1="100" y2="240" stroke="grey" stroke-width="1px"></line>
<line x1="350" x2="475" y1="100" y2="200" stroke="grey" stroke-width="1px"></line>
<line x1="350" x2="475" y1="100" y2="340" stroke="grey" stroke-width="1px"></line>
<line x1="350" x2="475" y1="100" y2="440" stroke="grey" stroke-width="1px"></line>
<line x1="350" x2="475" y1="240" y2="200" stroke="black" stroke-width="3px"></line>
<line x1="350" x2="475" y1="200" y2="100" stroke="grey" stroke-width="1px"></line>
<line x1="350" x2="475" y1="200" y2="240" stroke="grey" stroke-width="1px"></line>
<line x1="350" x2="475" y1="200" y2="200" stroke="grey" stroke-width="1px"></line>
<line x1="350" x2="475" y1="200" y2="340" stroke="grey" stroke-width="1px"></line>
<line x1="350" x2="475" y1="200" y2="440" stroke="grey" stroke-width="1px"></line>
<line x1="350" x2="475" y1="340" y2="300" stroke="black" stroke-width="3px"></line>
<line x1="350" x2="475" y1="300" y2="100" stroke="grey" stroke-width="1px"></line>
<line x1="350" x2="475" y1="300" y2="240" stroke="grey" stroke-width="1px"></line>
<line x1="350" x2="475" y1="300" y2="200" stroke="grey" stroke-width="1px"></line>
<line x1="350" x2="475" y1="300" y2="340" stroke="grey" stroke-width="1px"></line>
<line x1="350" x2="475" y1="300" y2="440" stroke="grey" stroke-width="1px"></line>
<line x1="350" x2="475" y1="440" y2="400" stroke="black" stroke-width="3px"></line>
<line x1="350" x2="475" y1="400" y2="100" stroke="grey" stroke-width="1px"></line>
<line x1="350" x2="475" y1="400" y2="240" stroke="grey" stroke-width="1px"></line>
<line x1="350" x2="475" y1="400" y2="200" stroke="grey" stroke-width="1px"></line>
<line x1="350" x2="475" y1="400" y2="340" stroke="grey" stroke-width="1px"></line>
<line x1="350" x2="475" y1="400" y2="440" stroke="grey" stroke-width="1px"></line>
<line x1="475" x2="600" y1="140" y2="100" stroke="black" stroke-width="3px"></line>
<line x1="475" x2="600" y1="100" y2="140" stroke="grey" stroke-width="1px"></line>
<line x1="475" x2="600" y1="100" y2="240" stroke="grey" stroke-width="1px"></line>
<line x1="475" x2="600" y1="100" y2="340" stroke="grey" stroke-width="1px"></line>
<line x1="475" x2="600" y1="100" y2="440" stroke="grey" stroke-width="1px"></line>
<line x1="475" x2="600" y1="240" y2="200" stroke="black" stroke-width="3px"></line>
<line x1="475" x2="600" y1="200" y2="140" stroke="grey" stroke-width="1px"></line>
<line x1="475" x2="600" y1="200" y2="240" stroke="grey" stroke-width="1px"></line>
<line x1="475" x2="600" y1="200" y2="340" stroke="grey" stroke-width="1px"></line>
<line x1="475" x2="600" y1="200" y2="440" stroke="grey" stroke-width="1px"></line>
<line x1="475" x2="600" y1="340" y2="300" stroke="black" stroke-width="3px"></line>
<line x1="475" x2="600" y1="300" y2="140" stroke="grey" stroke-width="1px"></line>
<line x1="475" x2="600" y1="300" y2="240" stroke="grey" stroke-width="1px"></line>
<line x1="475" x2="600" y1="300" y2="340" stroke="grey" stroke-width="1px"></line>
<line x1="475" x2="600" y1="300" y2="440" stroke="grey" stroke-width="1px"></line>
<line x1="475" x2="600" y1="440" y2="400" stroke="black" stroke-width="3px"></line>
<line x1="475" x2="600" y1="400" y2="140" stroke="grey" stroke-width="1px"></line>
<line x1="475" x2="600" y1="400" y2="240" stroke="grey" stroke-width="1px"></line>
<line x1="475" x2="600" y1="400" y2="340" stroke="grey" stroke-width="1px"></line>
<line x1="475" x2="600" y1="400" y2="440" stroke="grey" stroke-width="1px"></line>
<line x1="600" x2="725" y1="140" y2="100" stroke="black" stroke-width="3px"></line>
<line x1="600" x2="725" y1="100" y2="100" stroke="grey" stroke-width="1px"></line>
<line x1="600" x2="725" y1="100" y2="200" stroke="grey" stroke-width="1px"></line>
<line x1="600" x2="725" y1="100" y2="340" stroke="grey" stroke-width="1px"></line>
<line x1="600" x2="725" y1="100" y2="440" stroke="grey" stroke-width="1px"></line>
<line x1="600" x2="725" y1="240" y2="200" stroke="black" stroke-width="3px"></line>
<line x1="600" x2="725" y1="200" y2="100" stroke="grey" stroke-width="1px"></line>
<line x1="600" x2="725" y1="200" y2="200" stroke="grey" stroke-width="1px"></line>
<line x1="600" x2="725" y1="200" y2="340" stroke="grey" stroke-width="1px"></line>
<line x1="600" x2="725" y1="200" y2="440" stroke="grey" stroke-width="1px"></line>
<line x1="600" x2="725" y1="340" y2="300" stroke="black" stroke-width="3px"></line>
<line x1="600" x2="725" y1="300" y2="100" stroke="grey" stroke-width="1px"></line>
<line x1="600" x2="725" y1="300" y2="200" stroke="grey" stroke-width="1px"></line>
<line x1="600" x2="725" y1="300" y2="340" stroke="grey" stroke-width="1px"></line>
<line x1="600" x2="725" y1="300" y2="440" stroke="grey" stroke-width="1px"></line>
<line x1="600" x2="725" y1="440" y2="400" stroke="black" stroke-width="3px"></line>
<line x1="600" x2="725" y1="400" y2="100" stroke="grey" stroke-width="1px"></line>
<line x1="600" x2="725" y1="400" y2="200" stroke="grey" stroke-width="1px"></line>
<line x1="600" x2="725" y1="400" y2="340" stroke="grey" stroke-width="1px"></line>
<line x1="600" x2="725" y1="400" y2="440" stroke="grey" stroke-width="1px"></line>
<line x1="725" x2="850" y1="140" y2="100" stroke="black" stroke-width="3px"></line>
<line x1="725" x2="850" y1="100" y2="140" stroke="grey" stroke-width="1px"></line>
<line x1="725" x2="850" y1="100" y2="240" stroke="grey" stroke-width="1px"></line>
<line x1="725" x2="850" y1="100" y2="340" stroke="grey" stroke-width="1px"></line>
<line x1="725" x2="850" y1="100" y2="440" stroke="grey" stroke-width="1px"></line>
<line x1="725" x2="850" y1="240" y2="200" stroke="black" stroke-width="3px"></line>
<line x1="725" x2="850" y1="200" y2="140" stroke="grey" stroke-width="1px"></line>
<line x1="725" x2="850" y1="200" y2="240" stroke="grey" stroke-width="1px"></line>
<line x1="725" x2="850" y1="200" y2="340" stroke="grey" stroke-width="1px"></line>
<line x1="725" x2="850" y1="200" y2="440" stroke="grey" stroke-width="1px"></line>
<line x1="725" x2="850" y1="340" y2="300" stroke="black" stroke-width="3px"></line>
<line x1="725" x2="850" y1="300" y2="140" stroke="grey" stroke-width="1px"></line>
<line x1="725" x2="850" y1="300" y2="240" stroke="grey" stroke-width="1px"></line>
<line x1="725" x2="850" y1="300" y2="340" stroke="grey" stroke-width="1px"></line>
<line x1="725" x2="850" y1="300" y2="440" stroke="grey" stroke-width="1px"></line>
<line x1="725" x2="850" y1="440" y2="400" stroke="black" stroke-width="3px"></line>
<line x1="725" x2="850" y1="400" y2="140" stroke="grey" stroke-width="1px"></line>
<line x1="725" x2="850" y1="400" y2="240" stroke="grey" stroke-width="1px"></line>
<line x1="725" x2="850" y1="400" y2="340" stroke="grey" stroke-width="1px"></line>
<line x1="725" x2="850" y1="400" y2="440" stroke="grey" stroke-width="1px"></line>
<circle cx="100" cy="140" r="17" stroke="blue"></circle>
<circle cx="100" cy="100" r="17" stroke="red"></circle>
<circle cx="225" cy="140" r="17" stroke="blue"></circle>
<circle cx="225" cy="100" r="17" stroke="red"></circle>
<circle cx="225" cy="240" r="17" stroke="blue"></circle>
<circle cx="225" cy="200" r="17" stroke="red"></circle>
<circle cx="225" cy="340" r="17" stroke="blue"></circle>
<circle cx="225" cy="300" r="17" stroke="red"></circle>
<circle cx="225" cy="440" r="17" stroke="blue"></circle>
<circle cx="225" cy="400" r="17" stroke="red"></circle>
<circle cx="350" cy="140" r="17" stroke="blue"></circle>
<circle cx="350" cy="100" r="17" stroke="red"></circle>
<circle cx="350" cy="240" r="17" stroke="blue"></circle>
<circle cx="350" cy="200" r="17" stroke="red"></circle>
<circle cx="350" cy="340" r="17" stroke="blue"></circle>
<circle cx="350" cy="300" r="17" stroke="red"></circle>
<circle cx="350" cy="440" r="17" stroke="blue"></circle>
<circle cx="350" cy="400" r="17" stroke="red"></circle>
<circle cx="475" cy="140" r="17" stroke="blue"></circle>
<circle cx="475" cy="100" r="17" stroke="red"></circle>
<circle cx="475" cy="240" r="17" stroke="blue"></circle>
<circle cx="475" cy="200" r="17" stroke="red"></circle>
<circle cx="475" cy="340" r="17" stroke="blue"></circle>
<circle cx="475" cy="300" r="17" stroke="red"></circle>
<circle cx="475" cy="440" r="17" stroke="blue"></circle>
<circle cx="475" cy="400" r="17" stroke="red"></circle>
<circle cx="600" cy="140" r="17" stroke="blue"></circle>
<circle cx="600" cy="100" r="17" stroke="red"></circle>
<circle cx="600" cy="240" r="17" stroke="blue"></circle>
<circle cx="600" cy="200" r="17" stroke="red"></circle>
<circle cx="600" cy="340" r="17" stroke="blue"></circle>
<circle cx="600" cy="300" r="17" stroke="red"></circle>
<circle cx="600" cy="440" r="17" stroke="blue"></circle>
<circle cx="600" cy="400" r="17" stroke="red"></circle>
<circle cx="725" cy="140" r="17" stroke="blue"></circle>
<circle cx="725" cy="100" r="17" stroke="red"></circle>
<circle cx="725" cy="240" r="17" stroke="blue"></circle>
<circle cx="725" cy="200" r="17" stroke="red"></circle>
<circle cx="725" cy="340" r="17" stroke="blue"></circle>
<circle cx="725" cy="300" r="17" stroke="red"></circle>
<circle cx="725" cy="440" r="17" stroke="blue"></circle>
<circle cx="725" cy="400" r="17" stroke="red"></circle>
<circle cx="850" cy="140" r="17" stroke="blue"></circle>
<circle cx="850" cy="100" r="17" stroke="red"></circle>
<circle cx="850" cy="240" r="17" stroke="blue"></circle>
<circle cx="850" cy="200" r="17" stroke="red"></circle>
<circle cx="850" cy="340" r="17" stroke="blue"></circle>
<circle cx="850" cy="300" r="17" stroke="red"></circle>
<circle cx="850" cy="440" r="17" stroke="blue"></circle>
<circle cx="850" cy="400" r="17" stroke="red"></circle>
<text font-size="75%" x="100" y="140">8.5</text>
<text font-size="75%" x="100" y="100">8.4</text>
<text font-size="75%" x="225" y="140">6.8</text>
<text font-size="75%" x="225" y="100">7.5</text>
<text font-size="75%" x="225" y="240">7.8</text>
<text font-size="75%" x="225" y="200">7.5</text>
<text font-size="75%" x="225" y="340">8.8</text>
<text font-size="75%" x="225" y="300">7.5</text>
<text font-size="75%" x="225" y="440">9.8</text>
<text font-size="75%" x="225" y="400">7.5</text>
<text font-size="75%" x="350" y="140">6.0</text>
<text font-size="75%" x="350" y="100">5.8</text>
<text font-size="75%" x="350" y="240">7.0</text>
<text font-size="75%" x="350" y="200">5.8</text>
<text font-size="75%" x="350" y="340">8.0</text>
<text font-size="75%" x="350" y="300">5.8</text>
<text font-size="75%" x="350" y="440">9.0</text>
<text font-size="75%" x="350" y="400">5.8</text>
<text font-size="75%" x="475" y="140">4.0</text>
<text font-size="75%" x="475" y="100">5.0</text>
<text font-size="75%" x="475" y="240">5.0</text>
<text font-size="75%" x="475" y="200">5.0</text>
<text font-size="75%" x="475" y="340">6.0</text>
<text font-size="75%" x="475" y="300">5.0</text>
<text font-size="75%" x="475" y="440">7.0</text>
<text font-size="75%" x="475" y="400">5.0</text>
<text font-size="75%" x="600" y="140">3.5</text>
<text font-size="75%" x="600" y="100">3.0</text>
<text font-size="75%" x="600" y="240">4.5</text>
<text font-size="75%" x="600" y="200">3.0</text>
<text font-size="75%" x="600" y="340">5.5</text>
<text font-size="75%" x="600" y="300">3.0</text>
<text font-size="75%" x="600" y="440">6.5</text>
<text font-size="75%" x="600" y="400">3.0</text>
<text font-size="75%" x="725" y="140">1.0</text>
<text font-size="75%" x="725" y="100">2.5</text>
<text font-size="75%" x="725" y="240">2.0</text>
<text font-size="75%" x="725" y="200">2.5</text>
<text font-size="75%" x="725" y="340">3.0</text>
<text font-size="75%" x="725" y="300">2.5</text>
<text font-size="75%" x="725" y="440">4.0</text>
<text font-size="75%" x="725" y="400">2.5</text>
<text font-size="75%" x="850" y="140">1.0</text>
<text font-size="75%" x="850" y="100">0.0</text>
<text font-size="75%" x="850" y="240">2.0</text>
<text font-size="75%" x="850" y="200">0.0</text>
<text font-size="75%" x="850" y="340">3.0</text>
<text font-size="75%" x="850" y="300">0.0</text>
<text font-size="75%" x="850" y="440">4.0</text>
<text font-size="75%" x="850" y="400">0.0</text>
<text x="65" y="120">1</text>
<text x="65" y="220">2</text>
<text x="65" y="320">3</text>
<text x="65" y="420">4</text>
<text x="100" y="50">START</text>
<text x="225" y="50">1</text>
<text x="350" y="50">2</text>
<text x="475" y="50">3</text>
<text x="600" y="50">4</text>
<text x="725" y="50">5</text>
<text x="850" y="50">6</text>
<text font-weight="bold" transform="translate(25, 270) rotate(-90)">DICE ROLL</text>
<text x="475" y="25" font-weight="bold">TURN</text>
</svg>
```

We notice that for the opening turn, under the desire to maximize the expected pay-off, we should take the opening value of 1.

We are now ready to consider the full puzzle specification.

### Proposed Solution (Original Puzzle) {.tabset}



#### Strategy



* Note that, for the opening turn, the optimal strategy is to roll.
* The recommended approach for any given combination of turn/roll depends on the prior action, which will (in turn) depend on that die value at that time.
* Considering the recommended strategy where the prior action was to take the current value, there are _patches_ of turns/rolls which would never occur due to the chosen strategy; for example, we would never encounter a 2 where the prior value (which would also be 2) had been taken.
* Not surprisingly, if turn 99 had been a roll, we would always take the value for the subsequent turn 100.
* Prior to turn ~90, we never take the current value where it is below 6; instead, a roll is preferred.

![](SUMMARY_files/figure-html/unnamed-chunk-8-1.png)<!-- -->

#### Visits

* We see that for the majority of turns, we are less likely to achieve a die value of 1-5.
* Given that we predominantly take where the die value is at least 6, it makes sense that we would remain on numbers 6+ for longer relative to 1-5 above; this is because taking a die value maintains that value between adjacent turns.

![](SUMMARY_files/figure-html/unnamed-chunk-9-1.png)<!-- -->

#### Outcomes



* The maximum possible score was 1,000.
* The expected closing score, using the proposed strategy, is 560.6, as indicated by the vertical [red]{foreground="red"} line.
* Unlike the first variant, we obtain a bell-curve distribution for our closing scores.

![](SUMMARY_files/figure-html/unnamed-chunk-11-1.png)<!-- -->

## Third Variant

The rules are, again, as for the first variant, but with the following difference:

* Any time the player chooses to bank the current value, the "casino" can choose whether to roll the dice; this does not impact the amount taken, but does impact the die value for the next turn.

### Proposed Solution {.tabset}

The approach for the first variant has been extended as follows:

* After each time the player has taken the die value, the casino will choose to roll where this leads to a reduction in the expected future value.
* The player's decision will allow for this, assuming the casino will always act in the player's worst interest.



#### Strategy

* We note that the strategy is exactly as per the first variant.
* However, we note that the casino will **always** re-roll every time the player takes money; the only exception is the very last turn, by which point the casino's decision will not matter.

![](SUMMARY_files/figure-html/unnamed-chunk-12-1.png)<!-- -->

#### Visits

* With the first variant, the values where the player decided to take the die value were absorbing states; once reached, the player would never choose to roll again.
* Here, the casino can override this and, as seen in the strategy, will do so each time.
* We now note that, when using this strategy, each die value is equally likely across all turns.

![](SUMMARY_files/figure-html/unnamed-chunk-13-1.png)<!-- -->

#### Outcomes



* The maximum possible score was 2,000.
* The expected closing score, using the proposed strategy, is 416.1, as indicated by the vertical [red]{foreground="red"} line.
* Similar to the second variant, we obtain a bell-curve distribution for our closing scores; however, the impact of the casino has lead to a reduction in the expected closing score.

![](SUMMARY_files/figure-html/unnamed-chunk-15-1.png)<!-- -->
