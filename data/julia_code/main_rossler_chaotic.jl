using DifferentialEquations
using DelimitedFiles
using Random
# using GLMakie

# drift term
function rossler_drift(dstate, state, p, t)
	x, y, z = state
	a, b, c, ϵ₁, ϵ₂, ϵ₃ = p
    dstate[1] = -y-z
    dstate[2] = x+a*y
    dstate[3] = b + z*(x-c)
end

# diffusion term
function rossler_diffusion(dstate,state,p,t)
    a, b, c, ϵ₁, ϵ₂, ϵ₃ = p
    dstate[1] = ϵ₁
    dstate[2] = ϵ₂
    dstate[3] = ϵ₃
end

# parameters
a = 0.2
b = 0.2
c = 5.7
ϵ₁ = 0.0
ϵ₂ = 0.0
ϵ₃ = 0.0
p = (a, b, c, ϵ₁, ϵ₂, ϵ₃)

# output directories
filepath = "../datasets/"
filename = "rossler_chaotic"

# integration parameters
dt = 0.02
maxiters = 1e8
tin  = 0.0
tfin = 120000*dt
x₀ = 1.0
y₀ = 1.0
z₀ = 1.0
state₀ = [x₀, y₀, z₀]

# integration
prob_sde = SDEProblem(rossler_drift,rossler_diffusion,state₀,(tin,tfin),p)
sol = solve(prob_sde, SOSRA(), saveat=dt,maxiters=maxiters)

# save results
n_samples = length(sol.t)
n_samples2save = 100000
n_samplesdiff = n_samples - n_samples2save
t = zeros(n_samples2save)
x = zeros(n_samples2save)
y = zeros(n_samples2save)
z = zeros(n_samples2save)
for i = 1 : n_samples2save
    t[i] = sol.t[n_samplesdiff+i] - sol.t[n_samplesdiff+1]
    x[i] = sol.u[n_samplesdiff+i,1][1]
    y[i] = sol.u[n_samplesdiff+i,1][2]
    z[i] = sol.u[n_samplesdiff+i,1][3]
end
Y = zeros(n_samples2save,4)
Y[:,1] = t
Y[:,2] = x
Y[:,3] = y
Y[:,4] = z
writedlm(string(filepath, filename, ".txt"), Y)

# plot
# fontsize = 20
# fig = Figure(; size=(800, 600), fontsize=fontsize)
# ax = Axis3(fig[1, 1])
# lines!(ax, x, y, z, color=(:black,1.0));
# display(fig);
# save(string(filepath, filename, "_attractor.png"), fig)

# fig = Figure(; size=(800, 600), fontsize=fontsize)
# g1 = fig[1,1] = GridLayout();
# g2 = fig[2,1] = GridLayout();
# g3 = fig[3,1] = GridLayout();
# ax1 = Axis(g1[1,1], ylabel="x")
# lines!(ax1, t, x, color=(:black,1.0));
# ax2 = Axis(g2[1,1], ylabel="y")
# lines!(ax2, t, y, color=(:black,1.0));
# ax3 = Axis(g3[1,1], xlabel="t", ylabel="z")
# lines!(ax3, t, z, color=(:black,1.0));
# display(fig);
# save(string(filepath, filename, "_ts.png"), fig)