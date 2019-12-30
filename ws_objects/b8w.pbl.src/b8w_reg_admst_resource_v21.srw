$PBExportHeader$b8w_reg_admst_resource_v21.srw
$PBExportComments$[ohj] 장비자원등록 v21
forward
global type b8w_reg_admst_resource_v21 from w_a_reg_m_m
end type
type dw_file from datawindow within b8w_reg_admst_resource_v21
end type
type gb_1 from groupbox within b8w_reg_admst_resource_v21
end type
end forward

global type b8w_reg_admst_resource_v21 from w_a_reg_m_m
integer width = 3547
integer height = 2024
dw_file dw_file
gb_1 gb_1
end type
global b8w_reg_admst_resource_v21 b8w_reg_admst_resource_v21

type variables
String is_status[]
Long   i
end variables

forward prototypes
public subroutine of_resizepanels ()
end prototypes

public subroutine of_resizepanels ();//dw_detail.Width = 1850
end subroutine

on b8w_reg_admst_resource_v21.create
int iCurrent
call super::create
this.dw_file=create dw_file
this.gb_1=create gb_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_file
this.Control[iCurrent+2]=this.gb_1
end on

on b8w_reg_admst_resource_v21.destroy
call super::destroy
destroy(this.dw_file)
destroy(this.gb_1)
end on

event open;call super::open;string ls_ref_desc, ls_temp

dw_file.Enabled = False

//추가정보자원상태 미할당;할당  100;200
ls_ref_desc = ""
ls_temp = ""
ls_temp = fs_get_control("E1", "B100", ls_ref_desc)
If ls_temp = "" Then Return
fi_cut_string(ls_temp, ";", is_status[])
end event

event resize;//Window 크기를 변경하면 내부의 Object의 크기 및 위치를 자동 조정
//
If sizetype = 1 Then Return

SetRedraw(False)

If newheight < (dw_detail.Y + iu_cust_w_resize.ii_button_space) Then
	dw_detail.Height = 0

	p_insert.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_delete.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_save.Y		= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_reset.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
Else
	dw_detail.Height = newheight - dw_detail.Y - iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_dw_button_space 

	p_insert.Y	= newheight - iu_cust_w_resize.ii_button_space
	p_delete.Y	= newheight - iu_cust_w_resize.ii_button_space
	p_save.Y		= newheight - iu_cust_w_resize.ii_button_space
	p_reset.Y	= newheight - iu_cust_w_resize.ii_button_space
End If

If newwidth < dw_detail.X  Then
	dw_detail.Width = 0
Else
	dw_detail.Width = newwidth - dw_detail.X - iu_cust_w_resize.ii_dw_button_space
End If

// Call the resize functions
of_ResizeBars()
of_ResizePanels()

SetRedraw(True)

end event

event type integer ue_delete();call super::ue_delete;Long ll_row
Long ll_cnt

ll_row = dw_detail.getRow()

IF(ll_row > 1 ) THEN

	dw_detail.DeleteRow(ll_row)
	
//	FOR ll_cnt=ll_row to dw_detail.rowCount()
//		dw_detail.Object.num[ll_cnt] = dw_detail.Object.num[ll_cnt] -1
//	Next
	
	dw_master.Object.qty[1] = dw_detail.rowCount()

END IF

Return 0

end event

event type integer ue_extra_save();call super::ue_extra_save;Long		ll_rows, ll_rowcnt

//필수항목 Check
ll_rows	= dw_detail.RowCount()

//dw_master의 입고수량을 실제 입력된 row수로 정정한다.
dw_master.Object.qty[1] = ll_rows

FOR ll_rowcnt=1 TO ll_rows		
	dw_detail.Object.crt_user[ll_rowcnt]	= gs_user_id
	dw_detail.Object.crtdt[ll_rowcnt]		= fdt_get_dbserver_now()
	//dw_detail.Object.updt_user[ll_rowcnt]	= gs_user_id
	//dw_detail.Object.updtdt[ll_rowcnt]		= fdt_get_dbserver_now()
	dw_detail.Object.pgm_id[ll_rowcnt]		= gs_pgm_id[gi_open_win_no]
	
NEXT

//No Error
RETURN 0
end event

event type integer ue_insert();Constant Int LI_ERROR = -1
Long ll_row

ll_row = dw_detail.InsertRow(dw_detail.rowcount()+1)

//장비번호
//새 장비번호 추출
Long ll_adseq			//새 장비번호

SELECT seq_admst_resource.nextval
 INTO :ll_adseq
FROM dual;

dw_detail.Object.additionseq[ll_row]  = ll_adseq	//추가정보자원seq
dw_detail.Object.additiontype[ll_row] = dw_master.Object.additiontype[1]
dw_detail.Object.status[ll_row]	     = is_status[1]
dw_detail.Object.checknum[ll_row]	  = i

dw_detail.ScrollToRow(ll_row)
dw_detail.SetRow(ll_row)
dw_detail.SetFocus()

dw_master.Object.qty[1] = ll_row


Return 0

end event

event ue_ok();call super::ue_ok;long ll_cnt

//### 입고정보
String ls_additiontype, ls_item[]
Long	 ll_qty
String ls_ret_yn, ls_remark

If dw_master.AcceptText() < 1 Then
	//자료에 이상이 있다는 메세지 처리 요망
	dw_master.SetFocus()
	Return
End If

ls_additiontype = Trim(dw_master.Object.additiontype[1])
ll_qty          = dw_master.Object.qty[1]

//### 필수데이터 체크
//제조사
IF IsNull(ls_additiontype) THEN
	f_msg_usr_err(200, Title, "Addition 유형")
	dw_master.setColumn("additiontype")
	dw_master.setRow(1)
	dw_master.setFocus()
	RETURN
END IF

//입고수량
IF IsNull(ll_qty) THEN
	f_msg_usr_err(200, Title, "생성수량")
	dw_master.setColumn("qty")
	dw_master.setRow(1)
	dw_master.setFocus()
	RETURN
END IF

//### 입고거래 기타정보 입력
//입고자
//dw_master.Object.iman[1] = gs_user_id

////Log 정보
//dw_master.Object.crt_user[1] 	= gs_user_id
//dw_master.Object.crtdt[1] 		= fdt_get_dbserver_now()
//dw_master.Object.updt_user[1] = gs_user_id
//dw_master.Object.updtdt[1]		= fdt_get_dbserver_now()
//dw_master.Object.pgm_id[1]		= gs_pgm_id[gi_open_win_no]

select item01, item02, item03, item04, item05, item06, item07, item08, item09, item10
     , item11, item12, item13, item14, item15, item16, item17, item18, item19, item20
  into :ls_item[1], :ls_item[2], :ls_item[3], :ls_item[4], :ls_item[5], :ls_item[6], :ls_item[7], :ls_item[8], :ls_item[9], :ls_item[10]
     , :ls_item[11], :ls_item[12], :ls_item[13], :ls_item[14], :ls_item[15], :ls_item[16], :ls_item[17], :ls_item[18], :ls_item[19], :ls_item[20]
  from admst_additiontype
 where additiontype = :ls_additiontype ;
 
If sqlca.sqlcode < 0 Then
	f_msg_sql_err(This.Title, "Select Error(admst_additiontype)")
	Return 
End If

For i = 1 to UpperBound(ls_item)
	If isnull(ls_item[i]) Then
		i = i - 1
		Exit
	End If 
Next

//### 장비마스터 정보 입력
Long ll_detailRow //dw_detail의 row수
ll_detailRow = dw_detail.rowCount()

Long ll_adseq			//새 장비번호

//dw_detail의 row 수 > 입고정보에 입력된 입고수량
IF( ll_detailRow > ll_qty ) THEN
	FOR ll_cnt=ll_qty+1 TO ll_detailRow
		dw_detail.deleteRow(ll_qty+1)	//수량차이 만큼 dw_detail에 Row삭제
	Next
ELSEIF( ll_detailRow < ll_qty ) THEN
	FOR ll_cnt=ll_detailRow+1 TO ll_qty
		dw_detail.insertRow(ll_cnt)	//수량차이 만큼 dw_detail에 Row추가
		
			SELECT seq_admst_resource.nextval
			INTO :ll_adseq
			FROM dual;

		dw_detail.Object.additionseq[ll_cnt]	= ll_adseq
		dw_detail.Object.additiontype[ll_cnt] = dw_master.Object.additiontype[1]
		dw_detail.Object.status[ll_cnt]	     = is_status[1]
		dw_detail.Object.checknum[ll_cnt]	  = i
		
	Next
END IF

dw_detail.object.item01_t.text = ls_item[1]
dw_detail.object.item02_t.text = ls_item[2]
dw_detail.object.item03_t.text = ls_item[3]
dw_detail.object.item04_t.text = ls_item[4]
dw_detail.object.item05_t.text = ls_item[5]
dw_detail.object.item06_t.text = ls_item[6]
dw_detail.object.item07_t.text = ls_item[7]
dw_detail.object.item08_t.text = ls_item[8]
dw_detail.object.item09_t.text = ls_item[9]
dw_detail.object.item10_t.text = ls_item[10]
dw_detail.object.item11_t.text = ls_item[11]
dw_detail.object.item12_t.text = ls_item[12]
dw_detail.object.item13_t.text = ls_item[13]
dw_detail.object.item14_t.text = ls_item[14]
dw_detail.object.item15_t.text = ls_item[15]
dw_detail.object.item16_t.text = ls_item[16]
dw_detail.object.item17_t.text = ls_item[17]
dw_detail.object.item18_t.text = ls_item[18]
dw_detail.object.item19_t.text = ls_item[19]
dw_detail.object.item20_t.text = ls_item[20]

//File DW 활성화
dw_file.Enabled = True
dw_detail.Enabled = True

p_insert.TriggerEvent("ue_enable")
p_delete.TriggerEvent("ue_enable")
p_save.TriggerEvent("ue_enable")
p_reset.TriggerEvent("ue_enable")

end event

event type integer ue_reset();call super::ue_reset;p_ok.TriggerEvent("ue_enable")

p_insert.TriggerEvent("ue_disable")
p_delete.TriggerEvent("ue_disable")
p_save.TriggerEvent("ue_disable")
p_reset.TriggerEvent("ue_disable")

dw_detail.Enabled = False
dw_detail.reset()

dw_master.Enabled = True
dw_master.reset()
dw_master.insertRow(1)
//dw_master.Object.idate[1] = fdt_get_dbserver_now()
//dw_master.Object.modelno.Protect = True

dw_file.reset()
dw_file.insertRow(1)
dw_file.Enabled = False
RETURN 0

end event

type dw_cond from w_a_reg_m_m`dw_cond within b8w_reg_admst_resource_v21
boolean visible = false
integer x = 1957
integer y = 372
integer width = 631
integer height = 104
end type

type p_ok from w_a_reg_m_m`p_ok within b8w_reg_admst_resource_v21
integer x = 2464
integer y = 64
end type

type p_close from w_a_reg_m_m`p_close within b8w_reg_admst_resource_v21
integer x = 2464
integer y = 184
end type

type gb_cond from w_a_reg_m_m`gb_cond within b8w_reg_admst_resource_v21
boolean visible = false
integer x = 2039
integer y = 280
integer width = 649
integer height = 148
end type

type dw_master from w_a_reg_m_m`dw_master within b8w_reg_admst_resource_v21
event ue_cal ( )
integer x = 59
integer y = 76
integer width = 2167
integer height = 192
string dataobject = "b8dw_cnd_reg_admst_resource_v21"
boolean hscrollbar = false
boolean vscrollbar = false
boolean border = false
boolean hsplitscroll = false
boolean livescroll = false
end type

event dw_master::ue_cal;//공급가액과 부가세를 계산해주는 Event
this.AcceptText()

IF (not IsNull(THIS.Object.iqty[1])) AND (not IsNull(THIS.Object.idamt[1])) THEN
			THIS.Object.inamt[1]	= THIS.Object.iqty[1] * THIS.Object.idamt[1]	//공급가액
			THIS.Object.invat[1]	= Round(THIS.Object.inamt[1] *0.1,0)			//부가세
END IF
end event

event dw_master::clicked;//상속막음
end event

event dw_master::itemchanged;call super::itemchanged;This.AcceptText()

CHOOSE CASE UPPER(dwo.Name)
	CASE "IDAMT"
		TriggerEvent("ue_cal")

	CASE "IQTY"
		TriggerEvent("ue_cal")
		
	CASE "MAKERCD"
		//제조사에 해당하는 모델만 보여주기..
		DataWindowChild ldc
		String ls_filter
		Long ll_row
		ll_row = This.GetChild("modelno", ldc)
		If ll_row = -1 Then MessageBox("Error", "Not a DataWindowChild")
		ls_filter = "makercd = '" + This.Object.makercd[1] + "' "
		ldc.SetFilter(ls_filter)			//Filter정함
		ldc.Filter()
		ldc.SetTransObject(SQLCA)
		ll_row =ldc.Retrieve() 
	
		If ll_row < 0 Then 				//디비 오류 
			f_msg_usr_err(2100, Title, "Retrieve()")
			Return -2
		End If
		
		This.Object.modelno.Protect = False
		
	CASE "MODELNO"
		//제조사에 해당하는 모델만 보여주기..
		IF( IsNull(This.Object.makercd[1]) OR This.Object.makercd[1] = "") THEN
			f_msg_usr_err(200, Title, "제조사")
			//This.Object.modelno[1] = ""
			
			This.setColumn("makercd")
			This.setRow(1)
			This.setFocus()	
		END IF
		
END CHOOSE

end event

type dw_detail from w_a_reg_m_m`dw_detail within b8w_reg_admst_resource_v21
integer x = 32
integer y = 604
integer width = 3465
integer height = 1124
string dataobject = "b8dw_reg_admst_resource_v21"
end type

event dw_detail::constructor;call super::constructor;This.SetRowFocusIndicator(off!)
end event

type p_insert from w_a_reg_m_m`p_insert within b8w_reg_admst_resource_v21
integer y = 1752
end type

type p_delete from w_a_reg_m_m`p_delete within b8w_reg_admst_resource_v21
integer y = 1756
end type

type p_save from w_a_reg_m_m`p_save within b8w_reg_admst_resource_v21
integer y = 1756
end type

type p_reset from w_a_reg_m_m`p_reset within b8w_reg_admst_resource_v21
integer y = 1756
end type

type st_horizontal from w_a_reg_m_m`st_horizontal within b8w_reg_admst_resource_v21
integer x = 37
integer y = 560
string text = " "
end type

type dw_file from datawindow within b8w_reg_admst_resource_v21
integer x = 37
integer y = 328
integer width = 1522
integer height = 228
integer taborder = 50
boolean bringtotop = true
string title = "none"
string dataobject = "b8dw_file_reg_adin"
boolean livescroll = true
borderstyle borderstyle = stylelowered!
end type

event buttonclicked;call super::buttonclicked;CHOOSE CASE	dwo.Name
	CASE "search"	//파일찾기
		string pathName, fileName

		Int value

		value = GetFileOpenName("Select File", &
				+ pathName, fileName, "TXT", &
				+ "Text Files (*.TXT),*.TXT")

		IF value = 1 THEN
			This.Object.filename[1] = pathName
		END IF
		
	CASE "load"		//파일처리
		String 	ls_fileName
		Int		li_fileId
		
		ls_fileName = Trim(This.Object.filename[1])
		IF isNull(ls_fileName) THEN ls_fileName = ""
		
		IF ls_fileName = "" THEN
			f_msg_info(200, This.Title, "파일명")
			This.SetFocus()
			RETURN 0
		END IF
		
		li_fileId = FileOpen(ls_fileName, LineMode!) //한줄씩 읽어오기
		
		If(IsNull(li_fileId) or li_fileId < 0) THEN
			f_msg_usr_err(200, Title, "파일열기 실패")
			this.setFocus()
			RETURN 0
		End If
	
		String	ls_fileRow			//파일내용이 한줄 저장되는 변수
		String	ls_filedata[]
		Long		ll_fileRows = 0	//파일의 row수가 저장되는 변수
		Long		ll_iqty				//현재 입고예정인 row수
		Long 		ll_adseq				//새 장비번호
		Long		ll_row				//새로 입력된 row
		Long     ll_cnt
		
		ll_iqty = dw_detail.rowCount()
		
		//End of File(return -100)을 만날때까지 파일을 한줄씩 읽는다.
		DO UNTIL( FileRead(li_fileId,ls_fileRow) = -100 )
			
			IF(ls_fileRow <> "") THEN
			
				ll_fileRows++
				
				IF( ll_iqty < ll_fileRows) THEN //입고예정 수량보다 파일row수가 많은 경우
					ll_row = dw_detail.InsertRow(dw_detail.rowcount()+1)
	
					//장비번호
					//새 장비번호 추출
						SELECT seq_admst_resource.nextval
						INTO :ll_adseq
						FROM dual;
					
					dw_detail.Object.additionseq[ll_row]	= ll_adseq
					dw_detail.Object.additiontype[ll_row] = dw_master.Object.additiontype[1]
					dw_detail.Object.status[ll_row]	     = is_status[1]
					dw_detail.Object.checknum[ll_row]	  = i		
					//dw_detail.Object.num[ll_row] = ll_row
					
					dw_master.Object.qty[1] = ll_row
					
				END IF
			
				fi_cut_string(ls_fileRow,"~t", ls_filedata[])
				
				ll_cnt = UpperBound(ls_filedata[])
								
			   If ll_cnt > 0 Then
					dw_detail.Object.item01[ll_fileRows]   = ls_filedata[1]
				End If
				If ll_cnt > 1 Then
					dw_detail.Object.item02[ll_fileRows]   = ls_filedata[2]
				End If                     
				If ll_cnt > 2 Then         
					dw_detail.Object.item03[ll_fileRows]   = ls_filedata[3]
				End If                     
				If ll_cnt > 3 Then         
					dw_detail.Object.item04[ll_fileRows]   = ls_filedata[4]
				End If                     
				If ll_cnt > 4 Then         
					dw_detail.Object.item05[ll_fileRows]   = ls_filedata[5]
				End If                     
				If ll_cnt > 5 Then         
					dw_detail.Object.item06[ll_fileRows]   = ls_filedata[6]
				End If                     
				If ll_cnt > 6 Then         
					dw_detail.Object.item07[ll_fileRows]   = ls_filedata[7]
				End If                     
				If ll_cnt > 7 Then         
					dw_detail.Object.item08[ll_fileRows]   = ls_filedata[8]
				End If                     
				If ll_cnt > 8 Then         
					dw_detail.Object.item09[ll_fileRows]   = ls_filedata[9]
				End If
				If ll_cnt > 9 Then
					dw_detail.Object.item10[ll_fileRows]   = ls_filedata[10]
				End If                     
				If ll_cnt > 10 Then        
					dw_detail.Object.item11[ll_fileRows]   = ls_filedata[11]
				End If                     
				If ll_cnt > 11 Then        
					dw_detail.Object.item12[ll_fileRows]   = ls_filedata[12]
				End If                     
				If ll_cnt > 12 Then        
					dw_detail.Object.item13[ll_fileRows]   = ls_filedata[13]
				End If                     
				If ll_cnt > 13 Then        
					dw_detail.Object.item14[ll_fileRows]   = ls_filedata[14]
				End If                     
				If ll_cnt > 14 Then        
					dw_detail.Object.item15[ll_fileRows]   = ls_filedata[15]
				End If                     
				If ll_cnt > 15 Then        
					dw_detail.Object.item16[ll_fileRows]   = ls_filedata[16]
				End If                     
				If ll_cnt > 16 Then        
					dw_detail.Object.item17[ll_fileRows]   = ls_filedata[17]
				End If                     
				If ll_cnt > 17 Then        
					dw_detail.Object.item18[ll_fileRows]   = ls_filedata[18]
				End If                     
				If ll_cnt > 18 Then        
					dw_detail.Object.item19[ll_fileRows]   = ls_filedata[19]
				End If
				If ll_cnt > 19 Then
					dw_detail.Object.item20[ll_fileRows]   = ls_filedata[20]
				End If
			END IF	
		LOOP
		
		FileClose(li_fileId) //파일닫기
		
		//입력예정인 수량보다 파일에서 읽은 시리얼넘버가 작을 경우 경고
		IF(dw_detail.rowcount() > ll_fileRows) THEN
			MessageBox("Resource Item 부족","생성수량보다 파일로 입력된 Resource Item수량이 적습니다.")
			ll_fileRows++
		END IF
		
		//마지막 row로 간다.
		dw_detail.ScrollToRow(ll_fileRows)
		dw_detail.SetRow(ll_fileRows)
		dw_detail.SetFocus()
						
END CHOOSE
end event

event constructor;InsertRow(0)
end event

type gb_1 from groupbox within b8w_reg_admst_resource_v21
integer x = 37
integer y = 4
integer width = 2217
integer height = 296
integer taborder = 20
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 29478337
end type

