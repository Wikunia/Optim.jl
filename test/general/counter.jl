@testset "function counter" begin
    prob = Optim.UnconstrainedProblems.examples["Rosenbrock"]

    let
        global fcount = 0
        global fcounter
        function fcounter(reset::Bool = false)
            if reset
                fcount = 0
            else
                fcount += 1
            end
            fcount
        end
        global gcount = 0
        global gcounter
        function gcounter(reset::Bool = false)
            if reset
                gcount = 0
            else
                gcount += 1
            end
            gcount
        end
        global hcount = 0
        global hcounter
        function hcounter(reset::Bool = false)
            if reset
                hcount = 0
            else
                hcount += 1
            end
            hcount
        end
    end

    f(x) = begin
        fcounter()
        prob.f(x)
    end
    g!(out, x) = begin
        gcounter()
        prob.g!(out, x)
    end
    h!(out, x) = begin
        hcounter()
        prob.h!(out, x)
    end

    ls = LineSearches.Static()

    for solver in (AcceleratedGradientDescent, BFGS, ConjugateGradient,
                   GradientDescent, LBFGS, MomentumGradientDescent)
        fcounter(true); gcounter(true)
        res = Optim.optimize(f,g!, prob.initial_x,
                             solver(linesearch = ls))
        @test fcount == Optim.f_calls(res)
        @test gcount == Optim.g_calls(res)
    end

    for solver in (Newton(linesearch = ls), NewtonTrustRegion())
        fcounter(true); gcounter(true); hcounter(true)
        res = Optim.optimize(f,g!, h!, prob.initial_x,
                             solver)
        @test fcount == Optim.f_calls(res)
        @test gcount == Optim.g_calls(res)
        @test hcount == Optim.h_calls(res)
    end
end
