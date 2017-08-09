function RandomGaussian, npack, mu, sigma, seed=seed

if (mu EQ !null) then mu = 0.
if (sigma EQ !null) then sigma = 1.

u0 = random_nr(npack, seed=seed) 
u1 = random_nr(npack, seed=seed)
ypr = sin(2*!pi*u0) * sqrt(-2*alog(u1))
y = sigma*ypr + mu

return, y

end

