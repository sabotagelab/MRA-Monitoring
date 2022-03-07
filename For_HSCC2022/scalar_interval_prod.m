function J = scalar_interval_prod(s,I)
t = s*I;
J = [min(t), max(t)];