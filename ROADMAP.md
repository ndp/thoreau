## TODOs

* [x] focus on suite with a bang "suite!"
* [x] Shared setups
* [x] dynamic expects blocks
* [x] Multiple inputs support
* [x] focus on tests with a bang "happy!"
* [x] Legacy support
* [x] group of tests within suite, `test_cases`
* [ ] fix autorun
* [ ] allow expectations in the appendix
* [ ] make errors like nice (remove ` for #<#<Class:0x00007fc611a10e58>:0x00007fc611a10e08>`)
* [ ] embedded documentatoin as part of the test
* [ ] if there are no assertions, warn, "Do you want me to remember this for a legacy values?"
* [ ] test multiple outputs from the same setups
* Tighten up errors
  * [ ] complain if there's no testing/subject
  * [ ] warns about unused setups
  * [ ] warns about unused asserts
  * [ ] complains if there's more than one testing block
  * [ ] complains if there are no tests
  * [ ] what to do with a test with no expectations
* [ ] take to right line of code with better output
* [ ] More assertions / flexible evaluation
* [ ] create [minitest plugin?](https://github.com/fteem/how-to-write-minitest-extensions/blob/master/manuscript/4-writing-our-first-extension.md#adding-the-plugin)

Production ready?
* [ ] EXIT code 1 if failures
* [ ] Formatters for reporting


## Glossary
Test Case. What the QA engineer references to determine if a feature performs its function as expected. ...
Defect. Any deviation from an application's specifications. ...
Negative path testing. ...
Exploratory testing. ...
Regression testing. ...
Smoke tests. ...
Integration (interoperability) testing.
actual result
anomaly, defect, deviation, error, fault, failure, incident, problem
behavior: The response of a component or system to a set of input values and preconditions.

equivalence partition
equivalence partition: A portion of an input or output domain for which the behavior of a component or system is assumed to be the same, based on the specification.

equivalence partition coverage: The percentage of equivalence partitions that have been exercised by a test suite.

equivalence partitioning: A black box test design technique in which test cases are designed to execute representatives from equivalence partitions. In principle test cases are designed to cover each partition at least once


cause-effect graph: A graphical representation of inputs and/or stimuli (causes) with their associated outputs (effects), which can be used to design test cases.
boundary value: An input value or output value which is on the edge of an equivalence partition or at the smallest incremental distance on either side of an edge, for example the minimum or maximum value of a range.
configuration item:
data driven testing

boundary value analysis: A black box test design technique in which test cases are designed based on boundary values.

boundary value coverage: The percentage of boundary values that have been exercised by a test suite

pass/fail criteria: Decision rules used to determine whether a test item (function) or feature has passed or failed a test. [IEEE 829]


## Generate input data:
* https://hypothesis.works/articles/quickcheck-in-every-language/
* https://github.com/dubzzz/fast-check/blob/master/documentation/1-Guides/Arbitraries.md
* https://github.com/rantly-rb/rantly
* https://github.com/jsverify/jsverify
* https://hypothesis.readthedocs.io/en/latest/
* https://www.softwaretestinghelp.com/software-testing-terms-complete-glossary/
* https://begriffs.com/posts/2017-01-14-design-use-quickcheck.html -- good stuff on more complicated tests
* https://sites.google.com/site/unclebobconsultingllc/the-truth-about-bdd



# Vision

Although there are many testing tools, and we all have gotten into a groove using them,
it's easy to write lots of meaningless tests and have test coverage that doesn't really
test the code. I believe this is because of how the language of the tools is structured:
`it` or `spec` and `describe` and `context` are helpful in getting us started writing
tests. For TDD, they offer little friction to brainstorming behaviors for code. But, 
I believe, there's got to be something that is _more_ helpful.

QA test suites are about happy-path, regressions, edge cases. I believe
* the language we use does nothing to help us think of input/outputs for tests
* the language we use does nothing to facilitate finding edge cases and boundary
  conditions

These three artifacts are related:
* Requirements
* Tests:        FitNesse, xUnit/TDD
* Documentation

* Requirements/Tests: BDD, Cucumber, [Fit](http://fit.c2.com/wiki.cgi?FitWorkflow)
* Tests/Documentation:  Relish
* Testing the Documentation: test-pantry


# IDEAS

Deal with testing legacy apps. One would like to brainstorm setup 
scenarios and simply assert that they "never change". This requires
the creating of snapshots (or equivalent), but would be be useful
when not TDDing.

Design a tool for non-TDD. 
Q. How do I write tests for this existing app?
A. A simple answer is 
   1. identify equivalence classes of inputs
   2. record and assert that the values remain the same


# DSL ideas:

`invariant`
`edge`
`define`

define 'output of foo()' => :frozen

