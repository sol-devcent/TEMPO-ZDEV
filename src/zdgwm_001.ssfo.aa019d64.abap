DATA: ld_qty01(15),
      ld_qty02(15).

ld_qty01  = t_detail-qty01.
ld_qty02  = t_detail-qty02.
SHIFT ld_qty01 LEFT DELETING LEADING space.
SHIFT ld_qty02 LEFT DELETING LEADING space.
CONCATENATE ld_qty01 t_detail-uom01 INTO va_qty01
SEPARATED BY space.
CONCATENATE ld_qty02 t_detail-uom02 INTO va_qty02
SEPARATED BY space.





















