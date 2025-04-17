
one_column = 90
two_columns = 190

one_colum_inch = 90 * 0.0393701
two_columns_inch = 190 * 0.0393701

one_column_dpi = one_colum_inch * 150
two_columns_dpi = two_columns_inch * 150

#Harmonic ratio
one_column_size = (one_column_dpi, one_column_dpi / 1.618)
two_columns_size = (two_columns_dpi, two_columns_dpi / 1.618)
