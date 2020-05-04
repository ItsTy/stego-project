load_filename = input("Enter filename of the .mat file: ", 's');
if load_filename == ""
   load_filename = "jatte_original_decomp.mat"; 
end

hide_filename = input("Enter filename of the file to hide: ", 's');
if hide_filename == ""
   hide_filename = "hello.txt"; 
end

%Load files
load(load_filename);
temp_coefs = coefs;

hide_ID = fopen(hide_filename);
file_to_hide = fread(hide_ID);

fprintf("Size of coefs = %d\n", size(temp_coefs, 2))
fprintf("Size of data = %d\n", size(file_to_hide, 1))

temp_coefs = hide_in_coefs(temp_coefs, file_to_hide);

S.('coefs') = temp_coefs;
S.('sizes') = sizes;
save('hello.mat', '-struct', 'S')

ext = extract_file(temp_coefs, 4);

f_ID = fopen("extracted.txt", "w");
fwrite(f_ID, ext);

while(true)
    clc
    fprintf("Welcome to the Steganography Machine!\nPlease select one of the following options:\n\t1 Load Coefficients from a Decomposition\n\t2 Load File to Embed in Coefficients\n\t3 Hide Loaded File in Coefficients\n\t4 Extract File from Coefficients\n\t5 Save Coefficients\n\t6 Quit\n")
    selection = input("Please enter a number (1-6): ");
    switch(selection)
        case 1
            
        case 2
            
        case 3
            
        case 4
            
        case 5
            
        otherwise
            return
    end
end
    
%--------------------BEGIN FUNCTIONS--------------------%
function new_str = swap_bits(old_str, new_bits)
    %Replaces the last bits of bitstring old_str with the bits of new_str
    old_size = strlength(old_str);
    bits_size = strlength(new_bits);
    
    new_str = extractBetween(old_str, 1, old_size - bits_size) + new_bits;
end

function altered = hide_in_coefs(target, data)
    %Replaces the last n bits in each coefficient in target with part of the binary
    %code of data
    
    %Temp setup: each PAIR of 2 coefficient holds a byte
    %32-bit header to hold number of datapoints to read
    if size(target, 2) < 2 * size(data, 1) + 32
        fprintf("Error: Number of coefficients too small to hold data.\n");
        return
    end
    
    %Add data to beginning to determine how many values have been stored
    vals_to_read = string(dec2bin(size(data, 1), 32));
    vals_mat = [bin2dec(extractBetween(vals_to_read, 1, 8));
                bin2dec(extractBetween(vals_to_read, 9, 16));
                bin2dec(extractBetween(vals_to_read, 17, 24));
                bin2dec(extractBetween(vals_to_read, 25, 32))];
    
    data = [vals_mat; data];
    
    altered = target;
    for i = 1:size(data, 1)
        data_bits = string(dec2bin(data(i), 8));
        left_bits = extractBetween(data_bits, 1, 4);
        right_bits = extractBetween(data_bits, 5, 8);
        
        target_bits1 = string(dec2bin(altered(1, 2 * i - 1)));
        target_bits2 = string(dec2bin(altered(1, 2 * i)));
        
        target_bits1 = swap_bits(target_bits1, left_bits);
        target_bits2 = swap_bits(target_bits2, right_bits);
        
        altered(1, 2 * i - 1) = bin2dec(target_bits1);
        altered(1, 2 * i) = bin2dec(target_bits2);
    end
end

function extracted = extract_file(target, bits_per_coeff)


    %Determine how many values to read (using 32b tag at beginning of file)
    j = 1;
    num_to_read = "";
    while j * bits_per_coeff <= 32
        temp_coeff = string(dec2bin(target(1, j), 16));
        temp_substr = extractBetween(temp_coeff, 16 - bits_per_coeff + 1, 16);
        num_to_read = num_to_read + temp_substr;
        j = j + 1;
    end
    
    extracted = zeros(bin2dec(num_to_read), 1);
    for i = 1:bin2dec(num_to_read)
        temp_byte = "";
        k = 1;
        while k * bits_per_coeff <= 8
            temp_coeff = string(dec2bin(target(1, j), 16));
            temp_substr = extractBetween(temp_coeff, 16 - bits_per_coeff + 1, 16);
            temp_byte = temp_byte + temp_substr;
            j = j + 1;
            k = k + 1;
        end
        extracted(i) = bin2dec(temp_byte);
    end
end