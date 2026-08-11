DATA ld_ltx LIKE t247-ltx.

SELECT SINGLE ltx INTO ld_ltx
                  FROM t247
                  WHERE spras = 'i' AND
                        mnr = header-budat+4(2).

CONCATENATE header-budat+6(2) ld_ltx header-budat(4)
            INTO d_date_word SEPARATED BY space.


























