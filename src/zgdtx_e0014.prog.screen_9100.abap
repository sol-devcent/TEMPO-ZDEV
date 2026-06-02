PROCESS BEFORE OUTPUT.

  MODULE m_9100_status.

  MODULE m_9100_preparescreen.

  CALL SUBSCREEN s_9100_subscreen_header INCLUDING sy-repid '9300'.

*  CALL SUBSCREEN s_9100_subscreen_tax    INCLUDING sy-repid '9400'.

  LOOP AT    s_9100_table
       INTO  s_9100_table
       WITH  CONTROL s_9100_tc.

  ENDLOOP.

PROCESS AFTER INPUT.

  MODULE m_9100_exit AT EXIT-COMMAND.

  CALL SUBSCREEN s_9100_subscreen_header.

*  CALL SUBSCREEN s_9100_subscreen_tax.

  LOOP AT    s_9100_table.

    MODULE m_9100_read_table_control.
  ENDLOOP.

* CHECKING PROCESS :
* 1. Check Amount, Compare From Pevious

  CHAIN.
    FIELD: s_9100_io_namtlast1,
           s_9100_io_namtlast2,
           s_9100_io_namtlast3.

    MODULE m_9100_check_total_amt.
  ENDCHAIN.

* 2. Check Total DPP
  CHAIN.
    FIELD: s_9100_io_namtlast1,
           s_9100_io_namtlast2,
           s_9100_io_namtlast3.

    MODULE m_9100_check_total_amtlast.
  ENDCHAIN.

* 3. Check Amount, Compare From Pevious

  CHAIN.
    FIELD: s_9100_io_ndisc1,
           s_9100_io_ndisc2,
           s_9100_io_ndisc3.

    MODULE m_9100_check_total_disc.
  ENDCHAIN.

* 4. Check Total Discount
  CHAIN.
    FIELD: s_9100_io_ndisc1,
           s_9100_io_ndisc2,
           s_9100_io_ndisc3.

    MODULE m_9100_check_total_discount.
  ENDCHAIN.

  MODULE m_9100_user_command.

