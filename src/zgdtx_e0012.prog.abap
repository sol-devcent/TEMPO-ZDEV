*$*$ @description
*$*$  Closing Masa Pajak
*$*$
*$*$  Modification:
*$*$  1. Rahmadi (IBM) - Incorporating generic Company code & Branch
*$*$                     usage to the program
*$*$  2. Rahmadi (IBM) - MKM: Enable bi-monthly closing
*$*$--------------------------------------------------------------------

REPORT zgdtx_e0012
NO STANDARD PAGE HEADING
MESSAGE-ID ztx.

* Authorization checking macros
INCLUDE zabp_atz.

INCLUDE zgdtxne0012top.
INCLUDE zabp_alv_common.

SELECTION-SCREEN BEGIN OF BLOCK datac WITH FRAME TITLE d_title.
PARAMETERS: p_vkorg LIKE vbrk-vkorg MODIF ID cpc NO-DISPLAY,
            p_gsber LIKE vbrp-gsber MODIF ID cpc NO-DISPLAY.

**added by Rahmadi
PARAMETERS: p_bukrs LIKE t001-bukrs MODIF ID cpc,
            p_brnch LIKE zgdtxdt0101-brnch
                    OBLIGATORY MEMORY ID zbr MODIF ID cpc,
            p_hold  LIKE zgdtxdt0105-hcompany MODIF ID cpn.
**end of addition

PARAMETERS: p_masa  LIKE zgdtxdt0004-masatx,
            p_masan LIKE zgdtxdt0004-masatx MODIF ID cpn,
            p_zrra  LIKE zgdtxdt0002-pstyv DEFAULT 'ZRRA' NO-DISPLAY,
            p_zrin  LIKE zgdtxdt0002-pstyv DEFAULT 'ZRIN' NO-DISPLAY,
            p_fmasa(7) DEFAULT 'YYYY.MM' MODIF ID dsp.

SELECT-OPTIONS : s_vkorg FOR vbrk-vkorg NO-DISPLAY.
SELECTION-SCREEN END OF BLOCK datac.

INCLUDE zgdtxne0012f01.
INCLUDE zgdtxne0012o01.
INCLUDE zgdtxne0012i01.

AT SELECTION-SCREEN.
  PERFORM f_sel_screen.

AT SELECTION-SCREEN OUTPUT.
  PERFORM f_sel_screen_output.

AT SELECTION-SCREEN ON p_bukrs.
  macro_atz_single_bukrs p_bukrs c_atz_display.

INITIALIZATION.
  PERFORM f_initialization.

START-OF-SELECTION.
  PERFORM f_closing.

AT USER-COMMAND.
  PERFORM f_check_user_command.



*Text elements
*-------------
* IE03     Please enter Company code and/or branch!
* IE07     Branch does not belong to Company code
* IE66     Each branch
* II05     Next period is earlier than the previous one
* II07     Head office branch
* II09     National branch
* II10     Tax period has been closed
* II11     National tax period is still open
* II14     Tax period closing for branch
* II15     can not be performed
* II16     Tax period for Head office
* II17     has not been created
* II18     has no tax period created for
* II26     Head office tax period has been closed
* II77     Closing is simulated
* II82     Opened period will have impact to
* II83     Tax report A1 - A3 and B1 - B4
* IM01     Current tax period is invalid
* IM02     Next tax period is invalid
* IM03     must be closed via HO Tax Period Closing!
* IM88     Closing can only be performed
* IM99     after the tax period ends
* IP01     Tax period is about to be closed CENTRALLY
* IP02     NATIONAL Tax period has not been created
* IP11     Continue to open the branch tax period ?
* IPB1     Continue
* IPB3     Open period
* IPH1     Step Confirmation
* IS01     Closing process has successfully completed
* IS02     New National tax period creation is successful
* IS06     Tax period for branch
* IS07     has been successfully created
* IS11     Closing has been simulated



*Selection texts
*---------------
*SP_BRNCH         Branch
*SP_BUKRS         Company code
*SP_FMASA         Tax Period Format
*SP_HOLD          Holding Company Branch
*SP_MASA          Tax Period
*SP_MASAN         Next Tax Period
