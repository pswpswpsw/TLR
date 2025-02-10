using DifferentialEquations
using DelimitedFiles
using Random
# using GLMakie

# drift term
function lorenz_drift(dstate, state, p, t)
	x, y, z = state
	σ, β, ρ, ϵ₁, ϵ₂, ϵ₃ = p
    dstate[1] = σ*(y-x)
    dstate[2] = x*(ρ-z)-y
    dstate[3] = x*y - β*z
end

# diffusion term
function lorenz_diffusion(dstate,state,p,t)
    σ, β, ρ, ϵ₁, ϵ₂, ϵ₃ = p
    dstate[1] = ϵ₁
    dstate[2] = ϵ₂
    dstate[3] = ϵ₃
end

# parameters
σ = 10.0
β = 8/3
ρ = 28
ϵ₁ = 0.0
ϵ₂ = 0.0
ϵ₃ = 0.0
p = (σ, β, ρ, ϵ₁, ϵ₂, ϵ₃)

# output directories
filepath = "../datasets/"
filename = "lorenz_chaotic"

# integration parameters
dt = 0.005
maxiters = 1e8
tin  = 0.0
tfin = 140000*dt
x₀ = 0.6
y₀ = 0.2
z₀ = 0.1
state₀ = [x₀, y₀, z₀]

# integration
prob_sde = SDEProblem(lorenz_drift,lorenz_diffusion,state₀,(tin,tfin),p)
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