Blockchain-Racket
=================

My walkthrough of the outstanding [Introduction to Blockchain in Lisp](https://leanpub.com/ibl) book by [Boro Sitnikovski](https://bor0.wordpress.com/) with some additional code changes (lots of tests and documentation, [threading macros](https://docs.racket-lang.org/threading/index.html), code changes, etc.).

View the original project [here](https://github.com/MarkP88/racket-coin).

* [DrRacket 8.5](https://download.racket-lang.org/) reference platform.
* Tests included.

## Installation

1. Download this project.
2. Install [Racket](https://download.racket-lang.org/).
3. Install the dependencies. In the project root directory, execute in a shell: `make deps`.

## Example Usage

1. Run the first peer. In the project root directory, execute in a shell:

    ```bash
    racket src/main-p2p.rkt test.data 7000 127.0.0.1:7001,127.0.0.1:7002
    ```

2. You will see output like the following. When you do, press _control-c_ to break execution.

    ```bash
    Making genesis transaction...
    Mining genesis block...
    #<thread:export-loop>
    Mined a block!
    Exported blockchain to 'test.data'...
    ```

3. Run the second peer. In the project root directory, execute in a shell:

    ```bash
    racket src/main-p2p.rkt test2.data 7000 127.0.0.1:7001
    ```

4. To sync the peers, run the first peer again while keeping the second peer active. In the project root directory, execute in a shell:

    ```bash
    racket src/main-p2p.rkt test.data 7000 127.0.0.1:7001,127.0.0.1:7002
    ```

To run the tests, in the project root directory, execute in a shell:

```bash
make test
```

## Maintainer

Bracken Spencer

* [GitHub](https://www.github.com/brackendev)
* [LinkedIn](https://www.linkedin.com/in/brackenspencer/)
* [Twitter](https://twitter.com/brackendev)

## License

Blockchain-Racket is released under the GNU General Public License. See the LICENSE file for more info.

- - -

## Useful Links

* [/r/Racket](https://www.reddit.com/r/Racket/) [Reddit]
* [@racketlang](https://twitter.com/racketlang) [Twitter]
* [Boro Sitnikovski](https://bor0.wordpress.com/)
* [Getting Started](https://docs.racket-lang.org/getting-started/index.html) [racket-lang.org]
* [Introduction to Blockchain in Lisp](https://leanpub.com/ibl)
* [Racket](https://racket-lang.org/) [racket-lang.org]
* [Racket News](https://racket-news.com/)
