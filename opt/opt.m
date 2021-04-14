syms x1 x2 nu

f = x1^2 + 4*x2^2;
g = 4- x1^2 - 2*x2^2;

lagragian = f + nu * g;

diff_lagragian(1) = diff(lagragian,x1);
diff_lagragian(2) = diff(lagragian,x2);

eqns = [diff_lagragian == 0, nu>=0, nu*g==0, g<=0];

S = solve(eqns,x1,x2,nu);

candidate = zeros(3,length(S.x1));




candidate(1,:) = transpose(double(S.x1));
candidate(2,:) = transpose(double(S.x2));
candidate(3,:) = transpose(double(S.nu));


f_dif  = matlabFunction([diff(f,x1),diff(f,x2)]);

hess_f = matlabFunction(hessian(lagragian,[x1,x2]));


