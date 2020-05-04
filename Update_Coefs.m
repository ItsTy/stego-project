clc;
fprintf("Welcome to the Steganography Machine!")

while(true)
    fprintf("\nPlease select one of the following options:\n\t1 Load coefficients from a decomposition\n\t2 Load file to embed in coefficients\n\t3 Hide loaded file in coefficients\n\t4 Extract file from coefficients\n\t5 Save coefficients\n\t6 Quit\n")
    selection = input("Please enter a number (1-6): ");
    fprintf("Selection: %d\n\n", selection);
    if(isempty(selection))
        selection = 6;
    end
    switch(selection)
        case 1 %Load coefficients
            load_filename = input("Enter filename of the .mat file: ", 's');
            if load_filename == ""
               load_filename = "jatte_original_decomp.mat"; 
            end
            
            %Load file
            load(load_filename);
            temp_coefs = coefs;
            
            fprintf("'%s' loaded.\n", load_filename)
            
        case 2 %Load file to hide
            hide_filename = input("Enter filename of the file to hide: ", 's');
            if hide_filename == ""
               hide_filename = "hello.txt"; 
            end

            %Load file
            hide_ID = fopen(hide_filename);
            file_to_hide = fread(hide_ID);
            
            fprintf("'%s' loadad.\n", hide_filename);
            
        case 3 %Hide file
            if(~exist('temp_coefs', 'var') || ~exist('file_to_hide', 'var'))
                fprintf("ERROR: Coefficients or file not loaded.\n")
                continue
            end
            
            fprintf("Size of coefs = %d\n", size(temp_coefs, 2))
            fprintf("Size of data = %d\n", size(file_to_hide, 1))

            temp_coefs = hide_in_coefs(temp_coefs, file_to_hide);
            fprintf("File hidden in coefficients.\n")
            
        case 4 %Extract file
            if(~exist('temp_coefs', 'var'))
                fprintf("ERROR: Coefficients not loaded.\n")
                continue
            end
            
            ext = extract_file(temp_coefs, 4);
            save_file = input("Enter a filename to save extracted file. ", 's');
            if save_file == ""
                save_file = "extracted.txt";
            end
            
            f_ID = fopen(save_file, "w");
            fwrite(f_ID, ext);
            fprintf("Extracted file saved to %s.\n", save_file)
            
        case 5 %Save coefficients
            if(~exist('temp_coefs', 'var'))
                fprintf("ERROR: Coefficients not loaded.\n")
                continue
            end
            
            save_coefs = input("Enter a .mat filename to save coefficients: ", "s");
            S.('coefs') = temp_coefs;
            S.('sizes') = sizes;
            if save_coefs == ""
                save_coefs = "hello.mat";
            end
            
            save(save_coefs, '-struct', 'S')
            
        otherwise
            fprintf("Goodbye\n")
            if(exist('f_ID', 'var'))
                fclose(f_ID);
            end
            
            if(exist('hide_ID', 'var'))
                fclose(hide_ID);
            end
            clear;
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