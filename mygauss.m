function img = mygauss(img, sigma)
    %prepare the kernel first
    total = 0;
    kernelSize = 5;
    kernel = zeros(kernelSize,kernelSize);
    k = (kernelSize - 1) / 2;

    for i = 1:kernelSize
        for j = 1:kernelSize
            kernel(i,j) = exp((-1*((i-(k+1))^2+(j-(k+1))^2)) / (2*sigma^2)) / (2*pi*sigma^2);
            total = total + kernel(i,j);
        end
    end
    kernel = kernel / total;

    %apply the filter to the image
    [m,n] = size(img);
    gaussFiltered = zeros(m,n);
    padded = padarray(img,[2 2]);

    for i=1:m
        for j=1:n
            conv = double(padded(i:i+kernelSize-1, j:j+kernelSize-1)) .*kernel;
            gaussFiltered(i,j) = sum(conv(:));
        end
    end

    img = uint8(gaussFiltered);
end
