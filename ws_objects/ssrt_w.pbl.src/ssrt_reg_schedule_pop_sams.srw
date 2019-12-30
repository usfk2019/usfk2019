$PBExportHeader$ssrt_reg_schedule_pop_sams.srw
$PBExportComments$[1hera] 스케쥴관리
forward
global type ssrt_reg_schedule_pop_sams from window
end type
type p_4 from u_p_delete within ssrt_reg_schedule_pop_sams
end type
type dw_temp from datawindow within ssrt_reg_schedule_pop_sams
end type
type dw_detail from datawindow within ssrt_reg_schedule_pop_sams
end type
type p_3 from u_p_ok within ssrt_reg_schedule_pop_sams
end type
type p_2 from u_p_save within ssrt_reg_schedule_pop_sams
end type
type p_1 from u_p_close within ssrt_reg_schedule_pop_sams
end type
type dw_detail2 from datawindow within ssrt_reg_schedule_pop_sams
end type
type dw_cond from datawindow within ssrt_reg_schedule_pop_sams
end type
type gb_1 from groupbox within ssrt_reg_schedule_pop_sams
end type
end forward

global type ssrt_reg_schedule_pop_sams from window
integer width = 3173
integer height = 1916
boolean titlebar = true
boolean controlmenu = true
windowtype windowtype = response!
long backcolor = 29478337
event ue_close ( )
event type integer ue_save ( )
event type integer ue_extra_save ( )
event ue_ok ( )
event ue_delete ( )
p_4 p_4
dw_temp dw_temp
dw_detail dw_detail
p_3 p_3
p_2 p_2
p_1 p_1
dw_detail2 dw_detail2
dw_cond dw_cond
gb_1 gb_1
end type
global ssrt_reg_schedule_pop_sams ssrt_reg_schedule_pop_sams

type variables
u_cust_a_msg 	iu_cust_msg
String 	is_customerid, 	is_reqdt, 	is_userid, 	is_pgm_id, &
			is_basecod, 		is_control,	is_time[], &
			is_worktype[]
String 	is_emp_grp, is_schedule_type, is_svccod, is_priceplan
INTEGER	ii_maxnum, ii_troubleno, ii_time =  21 //Time의 간격수
LONG		il_troubleno,	il_schedule_seq
Boolean 	ib_order
date		idt_reqdt

end variables

event ue_close;iu_cust_msg.ib_data[1] = TRUE

IF IsNull(il_schedule_seq) THEN il_schedule_seq = 0

iu_cust_msg.is_data[1] = STRING(il_schedule_seq)		//스케줄 번호를 넘김...

Close(This)
end event

event type integer ue_save();Constant Int LI_ERROR = -1
Integer li_return, li_row
String ls_null
Dec    ldc_saleamt

If dw_detail2.AcceptText() < 0 Then
	dw_detail2.SetFocus()
	Return LI_ERROR
End If
li_return = Trigger Event ue_extra_save()
If li_return <0  Then
	dw_detail2.SetFocus()
	Return LI_ERROR
End If

f_msg_info(3000,This.Title,"Save")
TriggerEvent("ue_ok")
return 0
end event

event type integer ue_extra_save();INTEGER	li_worknum, li_count
Long		ll_seq
String 	ls_time, ls_partner, ls_descript

dw_detail.AcceptText()
ls_time 		= trim(dw_detail.Object.time[1])
ls_partner	= trim(dw_cond.Object.partner[1])
ls_descript	= trim(dw_detail.Object.remark[1])

If IsNull(ls_time) 		Then ls_time 		= ""
If IsNull(ls_partner) 	Then ls_partner 	= ""
If IsNull(ls_descript) 	Then ls_descript 	= ""

If ls_time = "" Then
	f_msg_info(200, Title, "TIME")
	dw_detail.SetFocus()
	dw_detail.SetColumn("time")
	Return -1
End If

If ls_partner = "" Then
	f_msg_info(200, Title, "PARTNER")
	dw_detail.SetFocus()
	dw_cond.SetColumn("partner")
	Return -1
End If

If ls_descript = "" Then
	f_msg_info(200, Title, "Description")
	dw_detail.SetFocus()
	dw_detail.SetColumn("remark")
	Return -1
End If


//최대직원수 및 스케쥴수 read
select workernum   INTO :li_worknum   FROM schedule_frame
 where partner = :ls_partner
   AND fromdt 	= ( select MAX(fromdt) from schedule_frame where  partner = :ls_partner)  ;
 
IF IsNull(li_worknum)  then li_worknum = 0
IF sqlca.sqlcode < 0 THEN
	Rollback ;
	f_msg_sql_err('Schedule Management', " schedule_frame - workernum")
	return -1
END IF

//  =========================================================================================
//  2008-03-18 hcjung   
//  스케쥴 갯수 가져오는 대상 테이블을 schedule_amount => schedule_detail 로 변경
//  schedule_amont 하는 곳 주석 처리
//  =========================================================================================
//SELECT count(*)   INTO :li_count  FROM schedule_amount
// WHERE partner 	= :ls_partner 
//   AND yyyymmdd 	= :ls_reqdt
//	AND worktime 	= :ls_time 	;

SELECT COUNT(*) INTO :li_count FROM schedule_detail
 WHERE partner_work	= :ls_partner
   AND yyyymmdd		= :is_reqdt
	AND worktime		= :ls_time;
 
IF IsNull(li_count)  then li_count = 0
IF sqlca.sqlcode < 0 THEN
	f_msg_sql_err('Schedule Management', " schedule_amount - Count")
	return -1
END IF

//최대직원수가 스케쥴수보다 크면 저장 및 update
IF li_worknum > li_count then
	Select seq_schedule_detail.nextval Into :ll_seq  From dual;
	  
	If SQLCA.SQLCode < 0 Then
		iu_cust_msg.il_data[1] = 0
		f_msg_sql_err('Schedule Management', "  seq_schedule_detail - Sequence Error")
		Return -1
	End If			

	GL_SCHEDULSEQ = ll_seq					//언넘인지 또라이 아이가... 글로벌 변수에 집어넣음...
	//스케쥴 번호를 넘겨주기 위해서!
	il_schedule_seq = ll_seq
	
	//partner_req 항목에 로그인샵으로 변경 요청함 - 이윤주 대리(2011.09.21)
	//현재는 파라미터로 open시 전달받은 user를 sysusr1t의 emp_group으로 처리하고 있었음.
	//2011.09.22 kem modify
	
	IF is_schedule_type = 'trouble' THEN
		INSERT INTO schedule_detail ( 
					scheduleseq,	yyyymmdd, 		worktime, 		WORKTYPE, 			requestdt, troubleno, svccod, priceplan,
					customerid, 	description,	partner_work, 	partner_req,		crt_user, crtdt )
		VALUES ( 
              :ll_seq, 			:is_reqdt, 		:ls_time, 		:is_worktype[2],	:idt_reqdt,  :il_troubleno, :is_svccod, :is_priceplan,
//				  :is_customerid,	:ls_descript,  :ls_partner,  	:is_emp_grp,  		:gs_user_id, sysdate
              :is_customerid,	:ls_descript,  :ls_partner,  	:GS_ShopID,  		:gs_user_id, sysdate
				  );
	ELSE		
		INSERT INTO schedule_detail ( 
					scheduleseq,	yyyymmdd, 		worktime, 		WORKTYPE, 			requestdt, 
					customerid, 	description,	partner_work, 	partner_req,		crt_user, crtdt )
		VALUES ( 
              :ll_seq, 			:is_reqdt, 		:ls_time, 		:is_worktype[1],	:idt_reqdt,  
//				  :is_customerid,	:ls_descript,  :ls_partner,  	:is_emp_grp,  		:gs_user_id, sysdate
				  :is_customerid,	:ls_descript,  :ls_partner,  	:GS_ShopID,  		:gs_user_id, sysdate
				  );
	END IF;
						
	If SQLCA.SQLCode < 0 Then
		GL_SCHEDULSEQ = 0
		f_msg_sql_err(Title, "SCHEDULE_DETAIL TABLE INSERT Error")
		Rollback ;
		RETURN -1
	End If
	
	li_count += 1
	//SCHEDULE_AMOUNT TABLE
//	IF li_count = 1 then
//		INSERT INTO schedule_amount ( partner, yyyymmdd, worktime,	fromdt,	count )
//		     VALUES ( :ls_partner, :is_reqdt, :ls_time,  sysdate,   :li_count	  ) ;
//	ELSE
//		UPDATE schedule_amount
//	      SET count = :li_count
//	    where partner 	= :ls_partner 
//	      AND yyyymmdd 	= :is_reqdt
//		   AND worktime 	= :ls_time 	;
//	end if

	If SQLCA.SQLCode < 0 Then
		f_msg_sql_err(Title, "SCHEDULE_AMOUNT TABLE UPDATE Error")
		GL_SCHEDULSEQ = 0
		Rollback ;
		RETURN -1
	End If
ELSE
	f_msg_info(9000, Title, "SCHEDULE IS FULL")
	rollback ;
	GL_SCHEDULSEQ = 0
	RETURN -1
END IF
//--저장 인식
Commit ;
dw_detail.SetitemStatus(1, 0, Primary!, NotModified!)
//p_save.TriggerEvent("ue_disable")		//버튼 비활성화

//dw_detail2.enabled = False

Return 0
	
end event

event ue_ok;long	ll_cnt,	ll_row,	ll_insert_cnt, ll, jj
String	ls_partner, ls_time

//----------------------------
// Time Define
// 2010-03-26 이윤주 대리 수정 요청. 시간을 AM 09:00 ~ PM 19:00 까지로 변경 요청함.
is_time[1] 	= '0900'
is_time[2] 	= '0930'
is_time[3] 	= '1000'
is_time[4] 	= '1030'
is_time[5] 	= '1100'
is_time[6] 	= '1130'
is_time[7] 	= '1200'
is_time[8] 	= '1230'
is_time[9] 	= '1300'
is_time[10] = '1330'
is_time[11] = '1400'
is_time[12] = '1430'
is_time[13] = '1500'
is_time[14] = '1530'
is_time[15] = '1600'
is_time[16] = '1630'
is_time[17] = '1700'
is_time[18] = '1730'
is_time[19] = '1800'
is_time[20] = '1830'
is_time[21] = '1900'

ls_partner =  trim(dw_cond.Object.partner[1])
If IsNull(ls_partner) then ls_partner = ''

If ls_partner = "" Then
	f_msg_info(200, Title, "Shop")
	dw_cond.SetFocus()
	dw_cond.SetColumn("partner")
	Return
End If

SELECT WORKERNUM INTO :ii_maxnum FROM SCHEDULE_FRAME
 WHERE PARTNER =  :ls_partner ;

IF IsNull(ii_maxnum) THEN ii_maxnum = 0
IF sqlca.sqlcode < 0 OR ii_maxnum = 0 THEN
		f_msg_sql_err(title, "Select SCHEDULE_FRAME Table")
		Return 
END IF

dw_detail2.Reset()
is_reqdt = String(dw_cond.Object.reqdt[1], 'yyyymmdd')
String 		ls_svc, ls_price, ls_work

FOR ll =  1 to ii_time
	ls_time 	= is_time[ll]
	ll_cnt 	= dw_temp.Retrieve(is_reqdt, ls_time, ls_partner)
	IF ll_cnt > 0 then
		FOR jj =  1 to ll_cnt
			ls_svc 		= dw_temp.describe("Evaluate('LookUpDisplay(svccod)'," + string(jj) +")") 
			ls_price 	= dw_temp.describe("Evaluate('LookUpDisplay(priceplan)'," + string(jj) +")") 
			ls_work 		= dw_temp.describe("Evaluate('LookUpDisplay(worktype)'," + string(jj) +")") 
			dw_temp.Object.svccod[jj] 		= ls_svc
			dw_temp.Object.priceplan[jj] 	= ls_price
			dw_temp.Object.worktype[jj] 	= ls_work
		NEXT
		
		
		dw_temp.RowsCopy(1, dw_temp.RowCount(), Primary!, dw_detail2, dw_detail2.RowCount() + 1, Primary!)
	END IF
	
	ll_insert_cnt	= ii_maxnum - ll_cnt
	IF ll_insert_cnt < 0 then ll_insert_cnt = 0
		IF ll_insert_cnt > 0 then
		for jj = 1 to ll_insert_cnt
			ll_row = dw_detail2.InsertRow(0)
			dw_detail2.Object.yyyymmdd[ll_row] 		= is_reqdt
			dw_detail2.Object.worktime[ll_row] 		= ls_time
			dw_detail2.Object.partner_work[ll_row] = ls_partner
			dw_detail2.Object.buildingno[ll_row] 	= ""
		NEXT
	END IF
NEXT	
return

end event

event ue_delete();Long ll_row, ll_SCHEDULESEQ
String ls_partner, ls_time
Integer li_count

ls_partner =  trim(dw_cond.Object.partner[1])


ll_row =  dw_detail2.GetRow()
IF ll_row > 0 THEN
	ll_SCHEDULESEQ = dw_detail2.Object.SCHEDULESEQ[ll_row]
	ls_time 			= trim(dw_detail2.Object.time[ll_row])
	
	delete from SCHEDULE_DETAIL
	 WHERE SCHEDULESEQ = :ll_SCHEDULESEQ ;
	 
	IF sqlca.sqlcode < 0 THEN
		Rollback ;
		f_msg_sql_err('SCHEDULE_DETAIL', " Not Deleted : " + SQLCA.SQLErrText )
		return 
	END IF
	
	select count INTO :li_count FROM schedule_amount
	    where partner 	= :ls_partner 
	      AND yyyymmdd 	= :is_reqdt
		   AND worktime 	= :ls_time 	;
	
	
	li_count --
	//SCHEDULE_AMOUNT TABLE Update
		UPDATE schedule_amount
	      SET count = :li_count
	    where partner 	= :ls_partner 
	      AND yyyymmdd 	= :is_reqdt
		   AND worktime 	= :ls_time 	;
	IF sqlca.sqlcode < 0 THEN
		Rollback ;
		f_msg_sql_err('schedule_amount', " Not Updated : " + SQLCA.SQLErrText )
		return 
	END IF
	
	Commit ;
	TriggerEvent("ue_ok")
END IF

return
end event

event open;///*------------------------------------------------------------------------
//	Name	:	ssrt_reg_schedule_popup_sams
//	Desc	: 	스케쥴관리
//	Ver.	:	1.0
//	Date	: 	2006.3.30
//	programer : Cho Kyung Bok[1hera]
//-------------------------------------------------------------------------*/
//String ls_paycod, ls_name[], ls_tmp, ls_ref_desc
Long 					ll_row
DataWindowChild 	ldwc
String 				ls_temp, is_partner

//윈도우 Title 설정
This.Title =  "Registraion of A/S Schedule"

is_customerid	= ""
is_reqdt 		= ""
is_userid 		= ""
is_pgm_id 		= ""
is_schedule_type = ""
ii_troubleno  = 0
il_troubleno  = 0
is_partner    = ""

iu_cust_msg = Create u_cust_a_msg
iu_cust_msg = Message.PowerObjectParm

dw_cond.SetTransObject(sqlca)
dw_detail2.SetTransObject(sqlca)
dw_detail.SetTransObject(sqlca)
//window 중앙에
f_center_window(this)

idt_reqdt  		  = iu_cust_msg.id_data[1]
is_customerid    = iu_cust_msg.is_data[1]
is_reqdt  		  = iu_cust_msg.is_data[2]
is_userid  		  = iu_cust_msg.is_data[3]
is_pgm_id        = iu_cust_msg.is_data[4]
//ii_troubleno     = Integer(iu_cust_msg.is_data[5])
il_troubleno     = LONG(iu_cust_msg.is_data[5])
is_schedule_type = iu_cust_msg.is_data[6]
is_svccod        = iu_cust_msg.is_data[7]
is_priceplan     = iu_cust_msg.is_data[8]
//is_partner       = iu_cust_msg.is_data[9]

String ls_ref_desc

select emp_group 
  into :is_emp_grp
  from sysusr1t 
 where emp_id =  :is_userid ;

IF IsNull(is_emp_grp) then is_emp_grp = ''
IF is_emp_grp <> '' then
	select basecod 
	  INTO :is_basecod
	  FROM partnermst
	 WHERE basecod = :is_emp_grp    ;
	 
	 IF sqlca.sqlcode <> 0 OR IsNull(is_basecod) then is_basecod = '000000'
EnD IF

is_control 	= fs_get_control("PI", "A101", ls_ref_desc)
IF IsNull(is_control) then is_control = '0'
// worktype
ls_temp	= fs_get_control("S1", "C100", ls_ref_desc)
fi_cut_string(ls_temp, ";", is_worktype[])



//String 		ls_filter
//INTEGER  	li_exist
//li_exist 	= dw_cond.GetChild("partner", ldwc)		//DDDW 구함
//If li_exist = -1 Then f_msg_usr_err(2100, Title, "GetChild() : Partner")
//ls_filter = "group_id = '" + is_control  + "' "
//
//ldwc.SetTransObject(SQLCA)
//li_exist =ldwc.Retrieve()
//ldwc.SetFilter(ls_filter)			//Filter정함
//ldwc.Filter()
		
//If li_exist < 0 Then 				
//  f_msg_usr_err(2100, Title, "Partner Retrieve()")
//  Return 1
//End If  

dw_cond.SetTransObject(sqlca)
dw_cond.InsertRow(0)
dw_cond.Object.reqdt[1] =  idt_reqdt
dw_cond.Object.partner[1] = is_partner

dw_detail.InsertRow(0)




end event

on ssrt_reg_schedule_pop_sams.create
this.p_4=create p_4
this.dw_temp=create dw_temp
this.dw_detail=create dw_detail
this.p_3=create p_3
this.p_2=create p_2
this.p_1=create p_1
this.dw_detail2=create dw_detail2
this.dw_cond=create dw_cond
this.gb_1=create gb_1
this.Control[]={this.p_4,&
this.dw_temp,&
this.dw_detail,&
this.p_3,&
this.p_2,&
this.p_1,&
this.dw_detail2,&
this.dw_cond,&
this.gb_1}
end on

on ssrt_reg_schedule_pop_sams.destroy
destroy(this.p_4)
destroy(this.dw_temp)
destroy(this.dw_detail)
destroy(this.p_3)
destroy(this.p_2)
destroy(this.p_1)
destroy(this.dw_detail2)
destroy(this.dw_cond)
destroy(this.gb_1)
end on

event close;iu_cust_msg.ib_data[1] = TRUE

IF IsNull(il_schedule_seq) THEN il_schedule_seq = 0

iu_cust_msg.is_data[1] = STRING(il_schedule_seq)		//스케줄 번호를 넘김...

//Destroy iu_cust_msg 
end event

type p_4 from u_p_delete within ssrt_reg_schedule_pop_sams
boolean visible = false
integer x = 1870
integer y = 60
boolean enabled = false
end type

type dw_temp from datawindow within ssrt_reg_schedule_pop_sams
boolean visible = false
integer x = 2574
integer y = 44
integer width = 617
integer height = 144
integer taborder = 20
string title = "none"
string dataobject = "ssrt_reg_schedule_pop_temp"
boolean livescroll = true
borderstyle borderstyle = stylelowered!
end type

event constructor;this.SetTransObject(sqlca)
end event

type dw_detail from datawindow within ssrt_reg_schedule_pop_sams
integer y = 1472
integer width = 3131
integer height = 336
integer taborder = 20
string title = "none"
string dataobject = "ssrt_reg_schedule_pop_detail"
boolean livescroll = true
borderstyle borderstyle = stylelowered!
end type

event constructor;SetTransObject(sqlca)
end event

type p_3 from u_p_ok within ssrt_reg_schedule_pop_sams
integer x = 2245
integer y = 60
boolean originalsize = false
end type

type p_2 from u_p_save within ssrt_reg_schedule_pop_sams
integer x = 2533
integer y = 60
boolean originalsize = false
end type

type p_1 from u_p_close within ssrt_reg_schedule_pop_sams
integer x = 2821
integer y = 60
boolean originalsize = false
end type

type dw_detail2 from datawindow within ssrt_reg_schedule_pop_sams
integer y = 236
integer width = 3131
integer height = 1216
integer taborder = 20
string title = "none"
string dataobject = "ssrt_reg_schedule_pop_list"
boolean hscrollbar = true
boolean vscrollbar = true
borderstyle borderstyle = stylelowered!
end type

event constructor;SetTransObject(sqlca)
end event

event clicked;THIS.selectRow(0, false)
THIS.selectRow(row, True)
end event

type dw_cond from datawindow within ssrt_reg_schedule_pop_sams
integer x = 91
integer y = 16
integer width = 1248
integer height = 204
integer taborder = 10
string title = "none"
string dataobject = "ssrt_cnd_reg_schedule_pop"
boolean border = false
boolean livescroll = true
end type

event constructor;SetTransObject(sqlca)
end event

type gb_1 from groupbox within ssrt_reg_schedule_pop_sams
integer x = 5
integer width = 3127
integer height = 232
integer taborder = 20
integer textsize = -2
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 29478337
borderstyle borderstyle = stylelowered!
end type

