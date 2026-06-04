# Random data
x = rand(10_000)
y = -2x .+ 0.15 .+ 0.01 * randn(10_000)

mutable struct Neuron
    w::Float64
    b::Float64

    Neuron() = new(0.25, 0.)
end

(m::Neuron)(x::Float64) = m.w * x + m.b

model = Neuron()

#= avoided thanks to `functor`
# function predict(m::Neuron, x::Float64)
    return m.w * x + m.b
end

predict(model, 5.) |> println
=#

model(-5.) |> println

loss = []
for i in 1:10_000
    y_pred = model(x[i])
    epsilon = y_pred - y[i]
    l = 1/2 * (epsilon)^2
    push!(loss, l)

    model.w -= 0.1 * epsilon * x[i]
    model.b -= 0.1 * epsilon
end

println(model.w, " ", model.b)

using Plots
unicodeplots() # switch to UnicodePlots
x = 1:0.1:5
plot(1:10_000, loss, label="data")
