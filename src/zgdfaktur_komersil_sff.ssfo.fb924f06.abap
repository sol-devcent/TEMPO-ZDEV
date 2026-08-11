CONCATENATE t_company-street_ship t_company-city1_ship
  INTO va_address_ship
  SEPARATED BY space.

SHIFT va_address_ship LEFT DELETING LEADING space.


























