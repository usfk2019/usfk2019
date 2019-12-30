$PBExportHeader$b0w_prt_zoncst2log.srw
$PBExportComments$[K.J.M] 대역별 요율 변경
forward
global type b0w_prt_zoncst2log from w_a_print
end type
end forward

global type b0w_prt_zoncst2log from w_a_print
integer width = 4133
end type
global b0w_prt_zoncst2log b0w_prt_zoncst2log

on b0w_prt_zoncst2log.create
call super::create
end on

on b0w_prt_zoncst2log.destroy
call super::destroy
end on

event open;call super::open;/*-------------------------------------------------------
	Name	: b0w_prt_zoncst2log
	Desc.	: 대역별 요율 변경
	Ver.	: 1.0
	Date	: 2004.08.31
	Programer : Kwon Jung Min(K.J.M)
---------------------------------------------------------*/

//작업선택을 기본요율로 default

dw_cond.object.parttype[1] = 'A'
end event

event ue_ok();call super::ue_ok;Long		ll_rows
String	ls_where
String	ls_priceplan, ls_zone,	ls_tmcod,	ls_opendt,	ls_parttype

ls_parttype = Trim(dw_cond.object.parttype[1])
IF ls_parttype = 'R' THEN	// 작업선택이 가격정책 요율이면 가격정책이 있어야 한다.
	ls_priceplan = Trim(dw_cond.object.priceplan[1])
ELSE
	ls_priceplan = 'ALL'
END IF

ls_zone = Trim(dw_cond.object.zoncod[1])
ls_tmcod = Trim(dw_cond.object.tmcod[1])
ls_opendt = Trim(String(dw_cond.object.opendt[1],'yyyymmdd'))

If( IsNull(ls_zone) ) Then ls_zone = ""
If( IsNull(ls_tmcod) ) Then ls_tmcod = ""
If( IsNull(ls_opendt) ) Then ls_opendt = ""

//Dynamic SQL
ls_where = ""

If( ls_priceplan <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where	+= "priceplan = '"+ ls_priceplan +"'"
End If

If( ls_zone <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where	+= "zoncod = '"+ ls_zone +"'"
End If

If( ls_tmcod <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where	+= "tmcod = '"+ ls_tmcod +"'"
End If

If( ls_opendt <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where	+= "to_char(crtdt,'yyyymmdd') >= '"+ ls_opendt +"'"
End If

dw_list.is_where	= ls_where
IF ls_opendt <> "" THEN
  dw_list.object.fromdt_t.visible = True
  dw_list.object.crtdt_t.visible = True
  dw_list.object.t_to.visible = True  
  dw_list.object.crtdt_t.text = LeftA(ls_opendt,4)+'-'+MidA(ls_opendt,5,2)+'-'+RightA(ls_opendt,2)
ELSE
  dw_list.object.fromdt_t.visible = False
  dw_list.object.crtdt_t.visible = False
  dw_list.object.t_to.visible = False
END IF
ll_rows	= dw_list.Retrieve()

If( ll_rows = 0 ) Then
	f_msg_info(1000, Title, "")
ElseIf( ll_rows < 0 ) Then
	f_msg_usr_err(2100, Title, "Retrieve()")
End If

end event

event ue_init();call super::ue_init;//페이지 설정
ii_orientation = 1 //세로0, 가로1
ib_margin = False
end event

event ue_reset();call super::ue_reset;//작업선택을 기본요율로 default

dw_cond.object.parttype[1] = 'A'
end event

type dw_cond from w_a_print`dw_cond within b0w_prt_zoncst2log
integer width = 3305
integer height = 208
string dataobject = "b0dw_cnd_prt_zoncst2log"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::itemchanged;call super::itemchanged;CHOOSE CASE dwo.name
	CASE 'parttype'		
		
		IF data = 'R' THEN			//가격정책 요율이면 보이고, 기본요율이면 안 보이게...
			
			This.object.priceplan_t.visible = 1
			This.object.priceplan.visible = 1	
			
			This.object.priceplan[row] = ""
		ELSE

			This.object.priceplan_t.visible = 0
			This.object.priceplan.visible = 0	
		END IF
		
		This.object.zoncod[row] = ""		
		This.object.tmcod[row] = ""	
END CHOOSE
end event

type p_ok from w_a_print`p_ok within b0w_prt_zoncst2log
integer x = 3497
end type

type p_close from w_a_print`p_close within b0w_prt_zoncst2log
integer x = 3799
end type

type dw_list from w_a_print`dw_list within b0w_prt_zoncst2log
integer y = 280
integer width = 4032
integer height = 1316
string dataobject = "b0dw_prt_zoncst2log"
end type

type p_1 from w_a_print`p_1 within b0w_prt_zoncst2log
end type

type p_2 from w_a_print`p_2 within b0w_prt_zoncst2log
end type

type p_3 from w_a_print`p_3 within b0w_prt_zoncst2log
end type

type p_5 from w_a_print`p_5 within b0w_prt_zoncst2log
end type

type p_6 from w_a_print`p_6 within b0w_prt_zoncst2log
end type

type p_7 from w_a_print`p_7 within b0w_prt_zoncst2log
end type

type p_8 from w_a_print`p_8 within b0w_prt_zoncst2log
end type

type p_9 from w_a_print`p_9 within b0w_prt_zoncst2log
end type

type p_4 from w_a_print`p_4 within b0w_prt_zoncst2log
end type

type gb_1 from w_a_print`gb_1 within b0w_prt_zoncst2log
end type

type p_port from w_a_print`p_port within b0w_prt_zoncst2log
end type

type p_land from w_a_print`p_land within b0w_prt_zoncst2log
end type

type gb_cond from w_a_print`gb_cond within b0w_prt_zoncst2log
integer width = 3387
integer height = 272
end type

type p_saveas from w_a_print`p_saveas within b0w_prt_zoncst2log
end type

