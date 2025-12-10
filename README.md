# Tests and Benchmarks for IHEP Multiloop

See the [project website](https://code.ihep.ac.cn/IHEP-Multiloop) for more information.

## Task List

- [ ] Testing FIRE7 in at https://gitlab.srcc.msu.ru/feynmanintegrals/fire, which also provides docker image at https://hub.docker.com/r/asmirnov80/fire.

- [ ] Test [`SeRA.jl`](https://code.ihep.ac.cn/IHEP-Multiloop/SeRA.jl).
    - [x] Prepare `SeRA.jl` testing environment.
    - [ ] (almost done) Test `SeRA.jl/test/workon_TSI/`
        - [x] Copy `externals/SeRA.jl/test/workon_TSI/` to `test/SeRA.jl_test_on_TSI/`
        - [x] Use `FIRE6` instead of `FIRE7` since `FIRE7` gives 0 master integrals during testing `workon_TSI` of `SeRA`.
        - [ ] Some modifications on `SeRA.jl` source code should be pushed to the main repository of `SeRA.jl`.
