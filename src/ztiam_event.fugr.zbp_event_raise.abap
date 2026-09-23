FUNCTION zbp_event_raise.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(EVENTID) TYPE  CHAR40
*"     VALUE(EVENTPARM) TYPE  CHAR40 DEFAULT SPACE
*"     VALUE(TARGET_INSTANCE) LIKE  MSXXLIST-NAME DEFAULT SPACE
*"     VALUE(TARGET_MODE) TYPE  BTCH0000-CHAR1 DEFAULT SPACE
*"  EXCEPTIONS
*"      BAD_EVENTID
*"      EVENTID_DOES_NOT_EXIST
*"      EVENTID_MISSING
*"      RAISE_FAILED
*"----------------------------------------------------------------------

***********************************************************************
*                             IMPORTANT                               *
***********************************************************************
*                                                                     *
*                  This function module is obsolete                   *
*                        Please do not use it                         *
*                                                                     *
*                                                                     *
*           This function module is planned to be deleted             *
*                                                                     *
*                                                                     *
*   Substitution:                                                     *
*   CALL METHOD cl_batch_event=>raise                                 *
*                                                                     *
***********************************************************************

  DATA:
    p_eventid   TYPE btceventid,
    p_eventparm TYPE btcevtparm,
    p_server    TYPE btcserver.

  p_eventid   = eventid.
  p_eventparm = eventparm.
  p_server    = target_instance.

  DATA: par_lb.
  DATA: rc TYPE i.

* d023157   24.9.2010   (note 1511784)
*
* - evaluate parameter target_mode
* - if target _mode is not 'L' and not 'B', check profile parameter
*   rdisp/bp_event_raise_lb
*
* B means load balancing, i.e. if no target instance has been
* specified, the event won't be processed necessarily on the local
* server, but on a randomly chosen server.
* Actually, our random algorithm is round robin for all
* calls of BP_EVENT_RAISE within the same process.

  IF ( target_instance IS INITIAL OR target_instance CO ' ' ).

    CALL 'C_SAPGPARAM'
        ID 'NAME'  FIELD 'rdisp/bp_event_raise_lb'
        ID 'VALUE' FIELD par_lb.

    IF target_mode = 'B'.
      PERFORM choose_lb_server CHANGING p_server rc.
    ELSE.
      IF target_mode NE 'L'.
        CALL 'C_SAPGPARAM'
        ID 'NAME'  FIELD 'rdisp/bp_event_raise_lb'
        ID 'VALUE' FIELD par_lb.

        IF par_lb = 'B'.
          PERFORM choose_lb_server CHANGING p_server rc.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

** end note 1511784 **********************************************
******************************************************************

  CALL METHOD cl_batch_event=>raise
    EXPORTING
      i_eventparm           = p_eventparm
      i_server              = p_server
      i_eventid             = p_eventid
    EXCEPTIONS
      excpt_raise_failed    = 1
      excpt_raise_forbidden = 3
      excpt_unknown_event   = 4
      excpt_no_authority    = 5
      OTHERS                = 6.
  CASE sy-subrc.
    WHEN 0.
      EXIT.
    WHEN 1 OR 3.
      RAISE raise_failed.
    WHEN 4.
      RAISE eventid_does_not_exist.
    WHEN OTHERS.
      RAISE raise_failed.
  ENDCASE.

ENDFUNCTION.

***********************************************************
* d023157    24.9.2010
*
*

FORM choose_lb_server USING lb_server TYPE btcserver
                                         p_rc TYPE i.

  STATICS: server_list LIKE msxxlist OCCURS 0 WITH HEADER LINE.

  DATA: batch LIKE msxxlist-msgtypes VALUE 8.
  STATICS: nr_of_servers TYPE i.

  STATICS: random_num TYPE i.

  p_rc = 1.

  IF nr_of_servers = 0.
    CALL FUNCTION 'TH_SERVER_LIST'
      EXPORTING
        services = batch
      TABLES
        list     = server_list
      EXCEPTIONS
        OTHERS   = 99.

    IF sy-subrc NE 0.
      EXIT.
    ENDIF.
  ENDIF.

  DESCRIBE TABLE server_list LINES nr_of_servers.

  IF nr_of_servers <= 0.
    EXIT.
  ENDIF.

  IF nr_of_servers = 1.
    READ TABLE server_list INDEX 1.
    IF sy-subrc = 0.
      lb_server = server_list-name.
      p_rc = 0.
    ENDIF.
    EXIT.
  ENDIF.

* if we don't have a random number yet, we create one.
* generate a random number between 1 and number of servers.
  IF random_num = 0.
    PERFORM get_random_number USING random_num nr_of_servers p_rc.
    IF p_rc NE 0.
      EXIT.
    ENDIF.
  ENDIF.

  READ TABLE server_list INDEX random_num.
  IF sy-subrc NE 0.
    EXIT.
  ENDIF.

  lb_server = server_list-name.
  p_rc = 0.

* increase random_num for the next access
  IF random_num >= nr_of_servers.
    random_num = 1.
  ELSE.
    random_num = random_num + 1.
  ENDIF.

ENDFORM.                    "choose_lb_server

********************************************************
* return a random number between 1 and max

FORM get_random_number USING p_random_num TYPE i
                                      max TYPE i
                                     p_rc TYPE i.

  STATICS: sv_seed TYPE i.
  STATICS: sv_prng TYPE REF TO cl_abap_random_int.

  DATA: now  TYPE tzntstmpl.


  p_rc = 0.

* we admit only non-negative numbers
  IF max < 1.
    p_rc = 1.
    EXIT.
  ENDIF.

  IF max = 1.
    p_random_num = 1.
    EXIT.
  ENDIF.

  IF ( sv_seed IS INITIAL ).
    GET TIME STAMP FIELD now.
    sv_seed = FRAC( now ) * 10000.
    sv_prng = cl_abap_random_int=>create( seed = sv_seed
                                           min = 1
                                           max = max ).
  ENDIF.

  p_random_num = sv_prng->get_next( ).

ENDFORM.                    "get_random_number
