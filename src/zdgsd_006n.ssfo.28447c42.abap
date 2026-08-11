CONCATENATE t_company-street_sold t_company-city1_sold
            t_company-suppl3_sold
  INTO va_address_sold
  SEPARATED BY space.

SHIFT va_address_sold LEFT DELETING LEADING space.






















