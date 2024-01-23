# Testing
We are straying from the typical Ruby/Serverspec setup in our test suite for a few reasons.

This repository is targeted at a broader audience than those experienced in Ruby. As a result, we chose more conventional naming schemes like `test/` over `spec/` as well as using parentheses over spaces.

With respect to Serverspec's convention of `describe`/`it`, we went with a more [mocha][] like approach which uses entirely strings for its contexts. We have found that this helps catch edge cases like IPv6 support.

[mocha]: https://github.com/mochajs/mocha

With respect to Serverspec's convention of using `be_*` matchers, we went with using `eq` when available. This has lead to easier to debug content (e.g. `file.mode`).
