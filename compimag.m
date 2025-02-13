function compimag(nomarch, tipo, umbral)
    % La función compimag 
    % Uso: compimag(nomarch, tipo, umbral)
    %
    % nomarch   Nombre del archivo con la imagen a comprimir.
    % tipo      Cadena que indica en formato de la imagen f.e. 'tif'.
    % umbral    Valor contra el que se comparan los coeficientes de la DFT,
    %           eliminando los menores a este valor.
    
    % Tamaño del bloque
    b_tam = [8 8];

    % 1. Lee y guarda los valores de luminancia de la imagen.
    arch = nomarch + '.' + tipo;
    if ~exist(arch, 'file')
        error('No existe el archivo: %s', arch);
    end
    
    img = im2gray( imread(arch) );
       
    % 4. Divide la imagen original.
    % 5. Aplica la DCT bidimensional a cada bloque.
    dct_b = @(block_struct) dct2(block_struct.data);
    m = blockproc(img, b_tam, dct_b);

    % 3. Calcula la entropía en la imagen original.
    h_og = entropy(m)
    
    % 6. Elimina los coeficientes menores al umbral.
    m_norm = (m - min(m(:))) / (max(m(:)) - min(m(:))) * 255;
    m_norm = abs(m_norm);
    masc = m_norm >= umbral;
    
    m = m .* masc;

    % 7. Calcula la entropía de la matriz de coeficientes.
    h_mc = entropy(m)

    % 8. Aplica la IDCT a cada bloque.
    idct_b = @(block_struct) idct2(block_struct.data);
    img_rec = blockproc(m, b_tam , idct_b);
    img_rec = uint8 (img_rec);

    % 10. Calcula el ECM entre la imagen comprimida y la original.
    img = double(img);
    img_rec = double(img_rec);

    error = img - img_rec;

    %%% Simplificación numel
    ECM_100 = ( sum(error(:).^2) / sum(img(:).^2) ) * 100;
    
    % 11. Estima el porcentaje de compresión.
    coef_nz = nnz(masc);
    totalPixeles = numel(img);
    comp = (1 - (coef_nz / totalPixeles)) * 100;
    
    % 9. Despliega el par de imágenes
    clf;
    imshowpair(img, img_rec, 'montage');
    
    pie_imagen = {['H_{Mo} = ' num2str(h_og, '%.4f') ' BITS'],...
                  ['H_{Mc} = ' num2str(h_mc, '%.4f') ' BITS']};

    annotation('textbox', [0.12, 0.2, 0.8, 0.05], 'String', pie_imagen, ...
    'EdgeColor', 'none', 'FontSize', 10, 'HorizontalAlignment', 'left', ...
    'FitBoxToText', 'on', 'FontName', 'Consolas');

    pie_imagen ={['ECM_{ }            = ' num2str(ECM_100, '%.4f') '%'],...
                 ['Compresión = ' num2str(comp, '%.4f') '%']};

    annotation('textbox', [0.320, 0.2, 0.8, 0.05], 'String', pie_imagen, ...
    'EdgeColor', 'none', 'FontSize', 10, 'HorizontalAlignment', 'left', ...
    'FitBoxToText', 'on', 'FontName', 'Consolas');
    
    pie_imagen = ['Umbral_{ }= ' num2str(umbral, '%d')];

    annotation('textbox', [0.560, 0.2, 0.8, 0.05], 'String', pie_imagen, ...
    'EdgeColor', 'none', 'FontSize', 10, 'HorizontalAlignment', 'left', ...
    'FitBoxToText', 'on', 'FontName', 'Consolas');
    
end