using DifferentialEquations
using DelimitedFiles
using Random
# using GLMakie

# Script modified after Gualandi et al., 2023, Deterministic and Stochastic
# Chaos Characterize Laboratory Earthquakes, EPSL.

# drift term
function springslider_drift(dstate, state, p, t)
	x, y, z, u = state
	κ, β₁, β₂, ρ, λ, ν, α, γ, ϵ₂, ϵ₄ = p
    expx = exp(x)
    dstate[3] = - ρ*(β₂*x + z)*expx
    dstate[4] = - α - γ*u + dstate[3]
	dstate[1] = (expx*((β₁-1)*x*(1+λ*u) + y - u) + κ*(1-expx) - dstate[4]*(1+λ*y)/(1+λ*u)) / (1 + λ*u + ν*expx)
    dstate[2] = κ*(1 - expx) - ν*expx*dstate[1]
end

# diffusion term
function springslider_diffusion(dstate,state,p,t)
    κ, β₁, β₂, ρ, λ, ν, α, γ, ϵ₂, ϵ₄ = p
    dstate[1] = 0.0
    dstate[2] = ϵ₂
    dstate[3] = 0.0
    dstate[4] = ϵ₄
end

# parameters
σₙ₀ = 17.379*1e6  # Reference normal stresses σₙ₀ [Pa] and experiment names
v₀ = 10e-6       # Loading velocity [m/s]
k  = 14.8*1e9    # Spring stiffness [Pa/m]
β₁ = 1.2         # b₁/a₀ [non-dim]
L₁ = 3*1e-6      # Critical distance for θ₁ [m]
ρ = 0.1
L₂ = ρ*L₁
a = 0.01         # Friction direct effect [non-dim]
μ₀ = 0.64        # Static friction coefficient [non-dim]
λ = a/μ₀
G = 31e9         # Rigidity modulus of quartz [Pa]
ρᵥ = 2.65e3      # Density of quartz [kg/m^3]
cₛ = sqrt(G/ρᵥ)
η₀ = G/(2*cₛ)
η = 15*η₀
p₀ = 1.01325e5   # Reference surrounding pressure (atmospheric pressure) [Pa]
βₐ = 1e-9        #[0.5-4]*1e-9 (David et al., 1994; see Segall and Rice, 1995)
βₘ = 1e-11       # Compressibility of Quartz (Pimienta et al., 2017, JGR, fig. 12)
ϕ₀ = 0.075       # Reference porosity
β = ϕ₀*(βₐ+βₘ)
ϵ = -0.017*1e-3  # Dilatancy/Compressibility coefficient
c₀ = 0.1          # Diffusivity [1/s]
γ = c₀*L₁/v₀

ϵₒₜ = 0.004*1e6  # Standard deviation on frictional shear stress τ [Pa]
ϵₒₛ = 0.006*1e6  # Standard deviation on normal stress σₙ [Pa]
ϵₜ = 0.5 * ϵₒₜ   # Noise level to perturb the dynamics on the frictional shear stress τ [Pa]
ϵₛ = 0.5 * ϵₒₛ   # Noise level to perturb the dynamics on the normal stress σₙ [Pa]


α = (c₀*p₀*L₁) / (v₀*λ*σₙ₀)
τ₀ = μ₀*σₙ₀
β₂ = -ϵ/(λ*β*σₙ₀)
κ = (k*L₁) / (a*σₙ₀)
ν = η*v₀ / (a*σₙ₀)
ϵ₂ = ϵₜ / (a*σₙ₀)
ϵ₄ = (1/λ)*ϵₛ/σₙ₀
# 8 parameters + 2 for the noise
# (the 9th parameter vstar is equal to v₀, so the ratio v₀ / vstar = 1
# and is already taken into account in the way the ODE/SDE are written)
p = (κ, β₁, β₂, ρ, λ, ν, α, γ, ϵ₂, ϵ₄)

# output directories
filepath = "../datasets/"
filename = "springslider_stochastic_chaotic"

# integration parameters
dt = 0.01
maxiters = 1e8
tin  = 0.0
tfin = 2050000*dt
x₀ = 0.05
y₀ = 0.0
z₀ = 0.0
u₀ = 0.0
state₀ = [x₀, y₀, z₀, u₀]

# integration
prob_sde = SDEProblem(springslider_drift,springslider_diffusion,state₀,(tin,tfin),p)
sol = solve(prob_sde, SOSRA(), saveat=dt,maxiters=maxiters)

# save results
n_samples = length(sol.t)
n_samples2save = 2000000
n_samplesdiff = n_samples - n_samples2save
t = zeros(n_samples2save)
x = zeros(n_samples2save)
y = zeros(n_samples2save)
z = zeros(n_samples2save)
u = zeros(n_samples2save)
for i = 1 : n_samples2save
    t[i] = sol.t[n_samplesdiff+i] - sol.t[n_samplesdiff+1]
    x[i] = sol.u[n_samplesdiff+i,1][1]
    y[i] = sol.u[n_samplesdiff+i,1][2]
    z[i] = sol.u[n_samplesdiff+i,1][3]
    u[i] = sol.u[n_samplesdiff+i,1][4]
end
Y = zeros(n_samples2save,5)
Y[:,1] = t
Y[:,2] = x
Y[:,3] = y
Y[:,4] = z
Y[:,5] = u
writedlm(string(filepath, filename, ".txt"), Y)
