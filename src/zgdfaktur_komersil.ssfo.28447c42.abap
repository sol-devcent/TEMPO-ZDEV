IF t_company-suppl3_sold IS INITIAL.
  CLEAR va_address_sold1.
  va_address_sold2 = t_company-name1_sold.
  CONCATENATE t_company-street_sold t_company-city1_sold
    INTO va_address_sold3
    SEPARATED BY space.
  SHIFT va_address_sold3 LEFT DELETING LEADING space.
ELSE.
  va_address_sold1 = t_company-name1_sold.
  CONCATENATE t_company-street_sold t_company-city1_sold
    INTO va_address_sold2
    SEPARATED BY space.
  va_address_sold3 = t_company-suppl3_sold.
  SHIFT va_address_sold2 LEFT DELETING LEADING space.
ENDIF.
























