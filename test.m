% for i = 1:2:size(new_coefs, 2)
%    new_coefs(1,i) = 0; 
% end
% 
% for i = 1:15
%    fprintf("%f\n", new_coefs(1,i)) 
% end
load("jatte_original_decomp.mat")
new_coefs = coefs;

min = Inf;
max = -1 * Inf;

for i = 1:size(new_coefs, 2)
    if new_coefs(1, i) < min
        min = new_coefs(1, i);
    end
    
    if new_coefs(1, i) > max
        max = new_coefs(1, i);
    end
end

fprintf("Max = %f\nMin = %f\n", max, min)

for i = 1:8 
    fprintf("%d bits: %s\n", i * 4, dec2bin(max, i * 4))
end

str_max = string(dec2bin(max, 16));
substr = extractBetween(str_max, 14,16);
fprintf("Max in Binary: %s\n", str_max);
str_max = extractBetween(str_max, 1, 13) + "111";
fprintf("Updated max:   %s\n", str_max)