defmodule Castile.Fixtures.XMLModels do
  @moduledoc false

  def org_model do
    {:model,
     [
       {:type, :_document, :sequence,
        [
          {:el,
           [
             {:alt, :"P:RecommendedItem", :"P:RecommendedItem", [], 1, 1, true, :undefined},
             {:alt, :"P:ArrayOfRecommendedItem", :"P:ArrayOfRecommendedItem", [], 1, 1, true,
              :undefined},
             {:alt, :"P:VSTimeScheduleLine", :"P:VSTimeScheduleLine", [], 1, 1, true, :undefined},
             {:alt, :"P:ArrayOfVSTimeScheduleLine", :"P:ArrayOfVSTimeScheduleLine", [], 1, 1,
              true, :undefined},
             {:alt, :"P:VSTimeSchedule", :"P:VSTimeSchedule", [], 1, 1, true, :undefined},
             {:alt, :"P:VSDateScheduleLine", :"P:VSDateScheduleLine", [], 1, 1, true, :undefined},
             {:alt, :"P:ArrayOfVSDateScheduleLine", :"P:ArrayOfVSDateScheduleLine", [], 1, 1,
              true, :undefined},
             {:alt, :"P:VSDateSchedule", :"P:VSDateSchedule", [], 1, 1, true, :undefined},
             {:alt, :"P:ValidationScheduleLine", :"P:ValidationScheduleLine", [], 1, 1, true,
              :undefined},
             {:alt, :"P:ArrayOfValidationScheduleLine", :"P:ArrayOfValidationScheduleLine", [], 1,
              1, true, :undefined},
             {:alt, :"P:ReplValidationSchedule", :"P:ReplValidationSchedule", [], 1, 1, true,
              :undefined},
             {:alt, :"P:ArrayOfReplValidationSchedule", :"P:ArrayOfReplValidationSchedule", [], 1,
              1, true, :undefined},
             {:alt, :"P:ReplValidationScheduleResponse", :"P:ReplValidationScheduleResponse", [],
              1, 1, true, :undefined},
             {:alt, :"P:ArrayOfHospAvailabilityRequest", :"P:ArrayOfHospAvailabilityRequest", [],
              1, 1, true, :undefined},
             {:alt, :"P:HospAvailabilityRequest", :"P:HospAvailabilityRequest", [], 1, 1, true,
              :undefined},
             {:alt, :"P:ArrayOfHospAvailabilityResponse", :"P:ArrayOfHospAvailabilityResponse",
              [], 1, 1, true, :undefined},
             {:alt, :"P:HospAvailabilityResponse", :"P:HospAvailabilityResponse", [], 1, 1, true,
              :undefined},
             {:alt, :"P:VSTimeScheduleType", :"P:VSTimeScheduleType", [], 1, 1, :simple,
              :undefined},
             {:alt, :"P:Login", :"P:Login", [], 1, 1, true, :undefined},
             {:alt, :"P:LoginResponse", :"P:LoginResponse", [], 1, 1, true, :undefined}
           ], 1, 1, :undefined, 3}
        ], [], :undefined, :undefined, 1, 1, 1, false, :undefined},
       {:type, :"P:VSTimeScheduleType", :sequence,
        [
          {:el,
           [
             {:alt, :"P:VSTimeScheduleType", {:"#PCDATA", :char}, [], 1, 1, true, :undefined}
           ], 1, 1, :undefined, 3}
        ], [], :undefined, :undefined, 2, 1, 1, false, :undefined},
       {:type, :"P:LoginResponse", :sequence,
        [
          {:el,
           [
             {:alt, :"P:LoginResult", :"P:MemberContact", [], 1, 1, true, :undefined}
           ], 0, 1, true, 3}
        ], [], :undefined, :undefined, 2, 1, 1, :undefined, :undefined},
       {:type, :"P:Login", :sequence,
        [
          {:el, [{:alt, :"P:userName", {:"#PCDATA", :char}, [], 1, 1, true, :undefined}], 0, 1,
           true, 3},
          {:el, [{:alt, :"P:password", {:"#PCDATA", :char}, [], 1, 1, true, :undefined}], 0, 1,
           true, 4},
          {:el, [{:alt, :"P:deviceId", {:"#PCDATA", :char}, [], 1, 1, true, :undefined}], 0, 1,
           true, 5}
        ], [], :undefined, :undefined, 4, 1, 1, :undefined, :undefined},
       {:type, :"P:HospAvailabilityResponse", :sequence,
        [
          {:el, [{:alt, :"P:IsDeal", {:"#PCDATA", :bool}, [], 1, 1, true, :undefined}], 0, 1,
           :undefined, 3},
          {:el, [{:alt, :"P:Number", {:"#PCDATA", :char}, [], 1, 1, true, :undefined}], 0, 1,
           true, 4},
          {:el, [{:alt, :"P:Quantity", {:"#PCDATA", :char}, [], 1, 1, true, :undefined}], 0, 1,
           :undefined, 5},
          {:el, [{:alt, :"P:StoreId", {:"#PCDATA", :char}, [], 1, 1, true, :undefined}], 0, 1,
           true, 6},
          {:el,
           [
             {:alt, :"P:UnitOfMeasure", {:"#PCDATA", :char}, [], 1, 1, true, :undefined}
           ], 0, 1, true, 7}
        ], [], :undefined, :undefined, 6, 1, 1, :undefined, :undefined},
       {:type, :"P:ArrayOfHospAvailabilityResponse", :sequence,
        [
          {:el,
           [
             {:alt, :"P:HospAvailabilityResponse", :"P:HospAvailabilityResponse", [], 1, 1, true,
              :undefined}
           ], 0, :unbound, true, 3}
        ], [], :undefined, :undefined, 2, 1, 1, :undefined, :undefined},
       {:type, :"P:HospAvailabilityRequest", :sequence,
        [
          {:el, [{:alt, :"P:ItemId", {:"#PCDATA", :char}, [], 1, 1, true, :undefined}], 0, 1,
           true, 3},
          {:el,
           [
             {:alt, :"P:UnitOfMeasure", {:"#PCDATA", :char}, [], 1, 1, true, :undefined}
           ], 0, 1, true, 4}
        ], [], :undefined, :undefined, 3, 1, 1, :undefined, :undefined},
       {:type, :"P:ArrayOfHospAvailabilityRequest", :sequence,
        [
          {:el,
           [
             {:alt, :"P:HospAvailabilityRequest", :"P:HospAvailabilityRequest", [], 1, 1, true,
              :undefined}
           ], 0, :unbound, true, 3}
        ], [], :undefined, :undefined, 2, 1, 1, :undefined, :undefined},
       {:type, :"P:ReplValidationScheduleResponse", :sequence,
        [
          {:el, [{:alt, :"P:LastKey", {:"#PCDATA", :char}, [], 1, 1, true, :undefined}], 0, 1,
           true, 3},
          {:el, [{:alt, :"P:MaxKey", {:"#PCDATA", :char}, [], 1, 1, true, :undefined}], 0, 1,
           true, 4},
          {:el,
           [
             {:alt, :"P:RecordsRemaining", {:"#PCDATA", {:integer, :int}}, [], 1, 1, true,
              :undefined}
           ], 0, 1, :undefined, 5},
          {:el,
           [
             {:alt, :"P:Schedules", :"P:ArrayOfReplValidationSchedule", [], 1, 1, true,
              :undefined}
           ], 0, 1, true, 6}
        ], [], :undefined, :undefined, 5, 1, 1, :undefined, :undefined},
       {:type, :"P:ArrayOfReplValidationSchedule", :sequence,
        [
          {:el,
           [
             {:alt, :"P:ReplValidationSchedule", :"P:ReplValidationSchedule", [], 1, 1, true,
              :undefined}
           ], 0, :unbound, true, 3}
        ], [], :undefined, :undefined, 2, 1, 1, :undefined, :undefined},
       {:type, :"P:ReplValidationSchedule", :sequence,
        [
          {:el,
           [
             {:alt, :"P:Description", {:"#PCDATA", :char}, [], 1, 1, true, :undefined}
           ], 0, 1, true, 3},
          {:el, [{:alt, :"P:Id", {:"#PCDATA", :char}, [], 1, 1, true, :undefined}], 0, 1, true,
           4},
          {:el, [{:alt, :"P:IsDeleted", {:"#PCDATA", :bool}, [], 1, 1, true, :undefined}], 0, 1,
           :undefined, 5},
          {:el,
           [
             {:alt, :"P:Lines", :"P:ArrayOfValidationScheduleLine", [], 1, 1, true, :undefined}
           ], 0, 1, true, 6}
        ], [], :undefined, :undefined, 5, 1, 1, :undefined, :undefined},
       {:type, :"P:ArrayOfValidationScheduleLine", :sequence,
        [
          {:el,
           [
             {:alt, :"P:ValidationScheduleLine", :"P:ValidationScheduleLine", [], 1, 1, true,
              :undefined}
           ], 0, :unbound, true, 3}
        ], [], :undefined, :undefined, 2, 1, 1, :undefined, :undefined},
       {:type, :"P:ValidationScheduleLine", :sequence,
        [
          {:el, [{:alt, :"P:Comment", {:"#PCDATA", :char}, [], 1, 1, true, :undefined}], 0, 1,
           true, 3},
          {:el,
           [
             {:alt, :"P:DateSchedule", :"P:VSDateSchedule", [], 1, 1, true, :undefined}
           ], 0, 1, true, 4},
          {:el,
           [
             {:alt, :"P:Description", {:"#PCDATA", :char}, [], 1, 1, true, :undefined}
           ], 0, 1, true, 5},
          {:el,
           [
             {:alt, :"P:LineNo", {:"#PCDATA", {:integer, :int}}, [], 1, 1, true, :undefined}
           ], 0, 1, :undefined, 6},
          {:el,
           [
             {:alt, :"P:Priority", {:"#PCDATA", {:integer, :int}}, [], 1, 1, true, :undefined}
           ], 0, 1, :undefined, 7},
          {:el,
           [
             {:alt, :"P:TimeSchedule", :"P:VSTimeSchedule", [], 1, 1, true, :undefined}
           ], 0, 1, true, 8}
        ], [], :undefined, :undefined, 7, 1, 1, :undefined, :undefined},
       {:type, :"P:VSDateSchedule", :sequence,
        [
          {:el,
           [
             {:alt, :"P:Description", {:"#PCDATA", :char}, [], 1, 1, true, :undefined}
           ], 0, 1, true, 3},
          {:el, [{:alt, :"P:Fridays", {:"#PCDATA", :bool}, [], 1, 1, true, :undefined}], 0, 1,
           :undefined, 4},
          {:el, [{:alt, :"P:Id", {:"#PCDATA", :char}, [], 1, 1, true, :undefined}], 0, 1, true,
           5},
          {:el,
           [
             {:alt, :"P:Lines", :"P:ArrayOfVSDateScheduleLine", [], 1, 1, true, :undefined}
           ], 0, 1, true, 6},
          {:el, [{:alt, :"P:Mondays", {:"#PCDATA", :bool}, [], 1, 1, true, :undefined}], 0, 1,
           :undefined, 7},
          {:el, [{:alt, :"P:Saturdays", {:"#PCDATA", :bool}, [], 1, 1, true, :undefined}], 0, 1,
           :undefined, 8},
          {:el, [{:alt, :"P:Sundays", {:"#PCDATA", :bool}, [], 1, 1, true, :undefined}], 0, 1,
           :undefined, 9},
          {:el, [{:alt, :"P:Thursdays", {:"#PCDATA", :bool}, [], 1, 1, true, :undefined}], 0, 1,
           :undefined, 10},
          {:el, [{:alt, :"P:Tuesdays", {:"#PCDATA", :bool}, [], 1, 1, true, :undefined}], 0, 1,
           :undefined, 11},
          {:el,
           [
             {:alt, :"P:ValidAllWeekdays", {:"#PCDATA", :bool}, [], 1, 1, true, :undefined}
           ], 0, 1, :undefined, 12},
          {:el,
           [
             {:alt, :"P:Wednesdays", {:"#PCDATA", :bool}, [], 1, 1, true, :undefined}
           ], 0, 1, :undefined, 13}
        ], [], :undefined, :undefined, 12, 1, 1, :undefined, :undefined},
       {:type, :"P:ArrayOfVSDateScheduleLine", :sequence,
        [
          {:el,
           [
             {:alt, :"P:VSDateScheduleLine", :"P:VSDateScheduleLine", [], 1, 1, true, :undefined}
           ], 0, :unbound, true, 3}
        ], [], :undefined, :undefined, 2, 1, 1, :undefined, :undefined},
       {:type, :"P:VSDateScheduleLine", :sequence,
        [
          {:el,
           [
             {:alt, :"P:EndingDate", {:"#PCDATA", :char}, [], 1, 1, true, :undefined}
           ], 0, 1, :undefined, 3},
          {:el, [{:alt, :"P:Exclude", {:"#PCDATA", :bool}, [], 1, 1, true, :undefined}], 0, 1,
           :undefined, 4},
          {:el,
           [
             {:alt, :"P:LineNo", {:"#PCDATA", {:integer, :int}}, [], 1, 1, true, :undefined}
           ], 0, 1, :undefined, 5},
          {:el,
           [
             {:alt, :"P:StartingDate", {:"#PCDATA", :char}, [], 1, 1, true, :undefined}
           ], 0, 1, :undefined, 6}
        ], [], :undefined, :undefined, 5, 1, 1, :undefined, :undefined},
       {:type, :"P:VSTimeSchedule", :sequence,
        [
          {:el,
           [
             {:alt, :"P:Description", {:"#PCDATA", :char}, [], 1, 1, true, :undefined}
           ], 0, 1, true, 3},
          {:el, [{:alt, :"P:Id", {:"#PCDATA", :char}, [], 1, 1, true, :undefined}], 0, 1, true,
           4},
          {:el,
           [
             {:alt, :"P:Lines", :"P:ArrayOfVSTimeScheduleLine", [], 1, 1, true, :undefined}
           ], 0, 1, true, 5},
          {:el, [{:alt, :"P:Type", {:"#PCDATA", :char}, [], 1, 1, true, :undefined}], 0, 1,
           :undefined, 6}
        ], [], :undefined, :undefined, 5, 1, 1, :undefined, :undefined},
       {:type, :"P:ArrayOfVSTimeScheduleLine", :sequence,
        [
          {:el,
           [
             {:alt, :"P:VSTimeScheduleLine", :"P:VSTimeScheduleLine", [], 1, 1, true, :undefined}
           ], 0, :unbound, true, 3}
        ], [], :undefined, :undefined, 2, 1, 1, :undefined, :undefined},
       {:type, :"P:VSTimeScheduleLine", :sequence,
        [
          {:el,
           [
             {:alt, :"P:DiningDurationCode", {:"#PCDATA", :char}, [], 1, 1, true, :undefined}
           ], 0, 1, true, 3},
          {:el, [{:alt, :"P:Period", {:"#PCDATA", :char}, [], 1, 1, true, :undefined}], 0, 1,
           true, 4},
          {:el,
           [
             {:alt, :"P:ReservationInterval", {:"#PCDATA", {:integer, :int}}, [], 1, 1, true,
              :undefined}
           ], 0, 1, :undefined, 5},
          {:el,
           [
             {:alt, :"P:SelectedByDefault", {:"#PCDATA", :bool}, [], 1, 1, true, :undefined}
           ], 0, 1, :undefined, 6},
          {:el, [{:alt, :"P:TimeFrom", {:"#PCDATA", :char}, [], 1, 1, true, :undefined}], 0, 1,
           :undefined, 7},
          {:el, [{:alt, :"P:TimeTo", {:"#PCDATA", :char}, [], 1, 1, true, :undefined}], 0, 1,
           :undefined, 8},
          {:el,
           [
             {:alt, :"P:TimeToIsPastMidnight", {:"#PCDATA", :bool}, [], 1, 1, true, :undefined}
           ], 0, 1, :undefined, 9}
        ], [], :undefined, :undefined, 8, 1, 1, :undefined, :undefined},
       {:type, :"P:ArrayOfRecommendedItem", :sequence,
        [
          {:el,
           [
             {:alt, :"P:RecommendedItem", :"P:RecommendedItem", [], 1, 1, true, :undefined}
           ], 0, :unbound, true, 3}
        ], [], :undefined, :undefined, 2, 1, 1, :undefined, :undefined},
       {:type, :"P:RecommendedItem", :sequence,
        [
          {:el, [{:alt, :"P:itemNo", {:"#PCDATA", :char}, [], 1, 1, true, :undefined}], 0, 1,
           true, 3},
          {:el, [{:alt, :"P:lift", {:"#PCDATA", :char}, [], 1, 1, true, :undefined}], 0, 1,
           :undefined, 4}
        ], [], :undefined, :undefined, 3, 1, 1, :undefined, :undefined}
     ],
     [
       {:ns, 'http://lsretail.com/LSOmniService/Base/2021', 'P', :qualified},
       {:ns, 'http://lsretail.com/LSOmniService/EComm/2017/Service', 'P', :qualified},
       {:ns, 'http://lsretail.com/LSOmniService/EComm/2017/Service/Imports', :undefined,
        :unqualified},
       {:ns, 'http://lsretail.com/LSOmniService/Loy/2021', 'P', :qualified},
       {:ns, 'http://www.w3.org/2001/XMLSchema', 'xsd', :qualified}
     ], 'http://lsretail.com/LSOmniService/EComm/2017/Service/Imports', [], true, :skip}
  end

  def overwrite_model do
    {:model,
     [
       {:type, :_document, :sequence,
        [
          {:el,
           [
             {:alt, :"ser:RecommendedItem", :"ser:RecommendedItem", [], 1, 1, true, :undefined},
             {:alt, :"ser:ArrayOfRecommendedItem", :"ser:ArrayOfRecommendedItem", [], 1, 1, true,
              :undefined},
             {:alt, :"ser:VSTimeScheduleLine", :"ser:VSTimeScheduleLine", [], 1, 1, true,
              :undefined},
             {:alt, :"ser:ArrayOfVSTimeScheduleLine", :"ser:ArrayOfVSTimeScheduleLine", [], 1, 1,
              true, :undefined},
             {:alt, :"ser:VSTimeSchedule", :"ser:VSTimeSchedule", [], 1, 1, true, :undefined},
             {:alt, :"ser:VSDateScheduleLine", :"ser:VSDateScheduleLine", [], 1, 1, true,
              :undefined},
             {:alt, :"ser:ArrayOfVSDateScheduleLine", :"ser:ArrayOfVSDateScheduleLine", [], 1, 1,
              true, :undefined},
             {:alt, :"ser:VSDateSchedule", :"ser:VSDateSchedule", [], 1, 1, true, :undefined},
             {:alt, :"ser:ValidationScheduleLine", :"ser:ValidationScheduleLine", [], 1, 1, true,
              :undefined},
             {:alt, :"ser:ArrayOfValidationScheduleLine", :"ser:ArrayOfValidationScheduleLine",
              [], 1, 1, true, :undefined},
             {:alt, :"ser:ReplValidationSchedule", :"ser:ReplValidationSchedule", [], 1, 1, true,
              :undefined},
             {:alt, :"ser:ArrayOfReplValidationSchedule", :"ser:ArrayOfReplValidationSchedule",
              [], 1, 1, true, :undefined},
             {:alt, :"ser:ReplValidationScheduleResponse", :"ser:ReplValidationScheduleResponse",
              [], 1, 1, true, :undefined},
             {:alt, :"ser:ArrayOfHospAvailabilityRequest", :"ser:ArrayOfHospAvailabilityRequest",
              [], 1, 1, true, :undefined},
             {:alt, :"ser:HospAvailabilityRequest", :"ser:HospAvailabilityRequest", [], 1, 1,
              true, :undefined},
             {:alt, :"ser:ArrayOfHospAvailabilityResponse",
              :"ser:ArrayOfHospAvailabilityResponse", [], 1, 1, true, :undefined},
             {:alt, :"ser:HospAvailabilityResponse", :"ser:HospAvailabilityResponse", [], 1, 1,
              true, :undefined},
             {:alt, :"ser:VSTimeScheduleType", :"ser:VSTimeScheduleType", [], 1, 1, :simple,
              :undefined},
             {:alt, :"ser:Login", :"ser:Login", [], 1, 1, true, :undefined},
             {:alt, :"ser:LoginResponse", :"ser:LoginResponse", [], 1, 1, true, :undefined}
           ], 1, 1, :undefined, 3}
        ], [], :undefined, :undefined, 1, 1, 1, false, :undefined},
       {:type, :"ser:VSTimeScheduleType", :sequence,
        [
          {:el,
           [
             {:alt, :"ser:VSTimeScheduleType", {:"#PCDATA", :char}, [], 1, 1, true, :undefined}
           ], 1, 1, :undefined, 3}
        ], [], :undefined, :undefined, 2, 1, 1, false, :undefined},
       {:type, :"ser:LoginResponse", :sequence,
        [
          {:el,
           [
             {:alt, :"ser:LoginResult", :"ser:MemberContact", [], 1, 1, true, :undefined}
           ], 0, 1, true, 3}
        ], [], :undefined, :undefined, 2, 1, 1, :undefined, :undefined},
       {:type, :"ser:Login", :sequence,
        [
          {:el, [{:alt, :"ser:userName", {:"#PCDATA", :char}, [], 1, 1, true, :undefined}], 0, 1,
           true, 3},
          {:el, [{:alt, :"ser:password", {:"#PCDATA", :char}, [], 1, 1, true, :undefined}], 0, 1,
           true, 4},
          {:el, [{:alt, :"ser:deviceId", {:"#PCDATA", :char}, [], 1, 1, true, :undefined}], 0, 1,
           true, 5}
        ], [], :undefined, :undefined, 4, 1, 1, :undefined, :undefined},
       {:type, :"ser:HospAvailabilityResponse", :sequence,
        [
          {:el, [{:alt, :"ser:IsDeal", {:"#PCDATA", :bool}, [], 1, 1, true, :undefined}], 0, 1,
           :undefined, 3},
          {:el, [{:alt, :"ser:Number", {:"#PCDATA", :char}, [], 1, 1, true, :undefined}], 0, 1,
           true, 4},
          {:el, [{:alt, :"ser:Quantity", {:"#PCDATA", :char}, [], 1, 1, true, :undefined}], 0, 1,
           :undefined, 5},
          {:el, [{:alt, :"ser:StoreId", {:"#PCDATA", :char}, [], 1, 1, true, :undefined}], 0, 1,
           true, 6},
          {:el,
           [
             {:alt, :"ser:UnitOfMeasure", {:"#PCDATA", :char}, [], 1, 1, true, :undefined}
           ], 0, 1, true, 7}
        ], [], :undefined, :undefined, 6, 1, 1, :undefined, :undefined},
       {:type, :"ser:ArrayOfHospAvailabilityResponse", :sequence,
        [
          {:el,
           [
             {:alt, :"ser:HospAvailabilityResponse", :"ser:HospAvailabilityResponse", [], 1, 1,
              true, :undefined}
           ], 0, :unbound, true, 3}
        ], [], :undefined, :undefined, 2, 1, 1, :undefined, :undefined},
       {:type, :"ser:HospAvailabilityRequest", :sequence,
        [
          {:el, [{:alt, :"ser:ItemId", {:"#PCDATA", :char}, [], 1, 1, true, :undefined}], 0, 1,
           true, 3},
          {:el,
           [
             {:alt, :"ser:UnitOfMeasure", {:"#PCDATA", :char}, [], 1, 1, true, :undefined}
           ], 0, 1, true, 4}
        ], [], :undefined, :undefined, 3, 1, 1, :undefined, :undefined},
       {:type, :"ser:ArrayOfHospAvailabilityRequest", :sequence,
        [
          {:el,
           [
             {:alt, :"ser:HospAvailabilityRequest", :"ser:HospAvailabilityRequest", [], 1, 1,
              true, :undefined}
           ], 0, :unbound, true, 3}
        ], [], :undefined, :undefined, 2, 1, 1, :undefined, :undefined},
       {:type, :"ser:ReplValidationScheduleResponse", :sequence,
        [
          {:el, [{:alt, :"ser:LastKey", {:"#PCDATA", :char}, [], 1, 1, true, :undefined}], 0, 1,
           true, 3},
          {:el, [{:alt, :"ser:MaxKey", {:"#PCDATA", :char}, [], 1, 1, true, :undefined}], 0, 1,
           true, 4},
          {:el,
           [
             {:alt, :"ser:RecordsRemaining", {:"#PCDATA", {:integer, :int}}, [], 1, 1, true,
              :undefined}
           ], 0, 1, :undefined, 5},
          {:el,
           [
             {:alt, :"ser:Schedules", :"ser:ArrayOfReplValidationSchedule", [], 1, 1, true,
              :undefined}
           ], 0, 1, true, 6}
        ], [], :undefined, :undefined, 5, 1, 1, :undefined, :undefined},
       {:type, :"ser:ArrayOfReplValidationSchedule", :sequence,
        [
          {:el,
           [
             {:alt, :"ser:ReplValidationSchedule", :"ser:ReplValidationSchedule", [], 1, 1, true,
              :undefined}
           ], 0, :unbound, true, 3}
        ], [], :undefined, :undefined, 2, 1, 1, :undefined, :undefined},
       {:type, :"ser:ReplValidationSchedule", :sequence,
        [
          {:el,
           [
             {:alt, :"ser:Description", {:"#PCDATA", :char}, [], 1, 1, true, :undefined}
           ], 0, 1, true, 3},
          {:el, [{:alt, :"ser:Id", {:"#PCDATA", :char}, [], 1, 1, true, :undefined}], 0, 1, true,
           4},
          {:el, [{:alt, :"ser:IsDeleted", {:"#PCDATA", :bool}, [], 1, 1, true, :undefined}], 0, 1,
           :undefined, 5},
          {:el,
           [
             {:alt, :"ser:Lines", :"ser:ArrayOfValidationScheduleLine", [], 1, 1, true,
              :undefined}
           ], 0, 1, true, 6}
        ], [], :undefined, :undefined, 5, 1, 1, :undefined, :undefined},
       {:type, :"ser:ArrayOfValidationScheduleLine", :sequence,
        [
          {:el,
           [
             {:alt, :"ser:ValidationScheduleLine", :"ser:ValidationScheduleLine", [], 1, 1, true,
              :undefined}
           ], 0, :unbound, true, 3}
        ], [], :undefined, :undefined, 2, 1, 1, :undefined, :undefined},
       {:type, :"ser:ValidationScheduleLine", :sequence,
        [
          {:el, [{:alt, :"ser:Comment", {:"#PCDATA", :char}, [], 1, 1, true, :undefined}], 0, 1,
           true, 3},
          {:el,
           [
             {:alt, :"ser:DateSchedule", :"ser:VSDateSchedule", [], 1, 1, true, :undefined}
           ], 0, 1, true, 4},
          {:el,
           [
             {:alt, :"ser:Description", {:"#PCDATA", :char}, [], 1, 1, true, :undefined}
           ], 0, 1, true, 5},
          {:el,
           [
             {:alt, :"ser:LineNo", {:"#PCDATA", {:integer, :int}}, [], 1, 1, true, :undefined}
           ], 0, 1, :undefined, 6},
          {:el,
           [
             {:alt, :"ser:Priority", {:"#PCDATA", {:integer, :int}}, [], 1, 1, true, :undefined}
           ], 0, 1, :undefined, 7},
          {:el,
           [
             {:alt, :"ser:TimeSchedule", :"ser:VSTimeSchedule", [], 1, 1, true, :undefined}
           ], 0, 1, true, 8}
        ], [], :undefined, :undefined, 7, 1, 1, :undefined, :undefined},
       {:type, :"ser:VSDateSchedule", :sequence,
        [
          {:el,
           [
             {:alt, :"ser:Description", {:"#PCDATA", :char}, [], 1, 1, true, :undefined}
           ], 0, 1, true, 3},
          {:el, [{:alt, :"ser:Fridays", {:"#PCDATA", :bool}, [], 1, 1, true, :undefined}], 0, 1,
           :undefined, 4},
          {:el, [{:alt, :"ser:Id", {:"#PCDATA", :char}, [], 1, 1, true, :undefined}], 0, 1, true,
           5},
          {:el,
           [
             {:alt, :"ser:Lines", :"ser:ArrayOfVSDateScheduleLine", [], 1, 1, true, :undefined}
           ], 0, 1, true, 6},
          {:el, [{:alt, :"ser:Mondays", {:"#PCDATA", :bool}, [], 1, 1, true, :undefined}], 0, 1,
           :undefined, 7},
          {:el, [{:alt, :"ser:Saturdays", {:"#PCDATA", :bool}, [], 1, 1, true, :undefined}], 0, 1,
           :undefined, 8},
          {:el, [{:alt, :"ser:Sundays", {:"#PCDATA", :bool}, [], 1, 1, true, :undefined}], 0, 1,
           :undefined, 9},
          {:el, [{:alt, :"ser:Thursdays", {:"#PCDATA", :bool}, [], 1, 1, true, :undefined}], 0, 1,
           :undefined, 10},
          {:el, [{:alt, :"ser:Tuesdays", {:"#PCDATA", :bool}, [], 1, 1, true, :undefined}], 0, 1,
           :undefined, 11},
          {:el,
           [
             {:alt, :"ser:ValidAllWeekdays", {:"#PCDATA", :bool}, [], 1, 1, true, :undefined}
           ], 0, 1, :undefined, 12},
          {:el,
           [
             {:alt, :"ser:Wednesdays", {:"#PCDATA", :bool}, [], 1, 1, true, :undefined}
           ], 0, 1, :undefined, 13}
        ], [], :undefined, :undefined, 12, 1, 1, :undefined, :undefined},
       {:type, :"ser:ArrayOfVSDateScheduleLine", :sequence,
        [
          {:el,
           [
             {:alt, :"ser:VSDateScheduleLine", :"ser:VSDateScheduleLine", [], 1, 1, true,
              :undefined}
           ], 0, :unbound, true, 3}
        ], [], :undefined, :undefined, 2, 1, 1, :undefined, :undefined},
       {:type, :"ser:VSDateScheduleLine", :sequence,
        [
          {:el,
           [
             {:alt, :"ser:EndingDate", {:"#PCDATA", :char}, [], 1, 1, true, :undefined}
           ], 0, 1, :undefined, 3},
          {:el, [{:alt, :"ser:Exclude", {:"#PCDATA", :bool}, [], 1, 1, true, :undefined}], 0, 1,
           :undefined, 4},
          {:el,
           [
             {:alt, :"ser:LineNo", {:"#PCDATA", {:integer, :int}}, [], 1, 1, true, :undefined}
           ], 0, 1, :undefined, 5},
          {:el,
           [
             {:alt, :"ser:StartingDate", {:"#PCDATA", :char}, [], 1, 1, true, :undefined}
           ], 0, 1, :undefined, 6}
        ], [], :undefined, :undefined, 5, 1, 1, :undefined, :undefined},
       {:type, :"ser:VSTimeSchedule", :sequence,
        [
          {:el,
           [
             {:alt, :"ser:Description", {:"#PCDATA", :char}, [], 1, 1, true, :undefined}
           ], 0, 1, true, 3},
          {:el, [{:alt, :"ser:Id", {:"#PCDATA", :char}, [], 1, 1, true, :undefined}], 0, 1, true,
           4},
          {:el,
           [
             {:alt, :"ser:Lines", :"ser:ArrayOfVSTimeScheduleLine", [], 1, 1, true, :undefined}
           ], 0, 1, true, 5},
          {:el, [{:alt, :"ser:Type", {:"#PCDATA", :char}, [], 1, 1, true, :undefined}], 0, 1,
           :undefined, 6}
        ], [], :undefined, :undefined, 5, 1, 1, :undefined, :undefined},
       {:type, :"ser:ArrayOfVSTimeScheduleLine", :sequence,
        [
          {:el,
           [
             {:alt, :"ser:VSTimeScheduleLine", :"ser:VSTimeScheduleLine", [], 1, 1, true,
              :undefined}
           ], 0, :unbound, true, 3}
        ], [], :undefined, :undefined, 2, 1, 1, :undefined, :undefined},
       {:type, :"ser:VSTimeScheduleLine", :sequence,
        [
          {:el,
           [
             {:alt, :"ser:DiningDurationCode", {:"#PCDATA", :char}, [], 1, 1, true, :undefined}
           ], 0, 1, true, 3},
          {:el, [{:alt, :"ser:Period", {:"#PCDATA", :char}, [], 1, 1, true, :undefined}], 0, 1,
           true, 4},
          {:el,
           [
             {:alt, :"ser:ReservationInterval", {:"#PCDATA", {:integer, :int}}, [], 1, 1, true,
              :undefined}
           ], 0, 1, :undefined, 5},
          {:el,
           [
             {:alt, :"ser:SelectedByDefault", {:"#PCDATA", :bool}, [], 1, 1, true, :undefined}
           ], 0, 1, :undefined, 6},
          {:el, [{:alt, :"ser:TimeFrom", {:"#PCDATA", :char}, [], 1, 1, true, :undefined}], 0, 1,
           :undefined, 7},
          {:el, [{:alt, :"ser:TimeTo", {:"#PCDATA", :char}, [], 1, 1, true, :undefined}], 0, 1,
           :undefined, 8},
          {:el,
           [
             {:alt, :"ser:TimeToIsPastMidnight", {:"#PCDATA", :bool}, [], 1, 1, true, :undefined}
           ], 0, 1, :undefined, 9}
        ], [], :undefined, :undefined, 8, 1, 1, :undefined, :undefined},
       {:type, :"ser:ArrayOfRecommendedItem", :sequence,
        [
          {:el,
           [
             {:alt, :"ser:RecommendedItem", :"ser:RecommendedItem", [], 1, 1, true, :undefined}
           ], 0, :unbound, true, 3}
        ], [], :undefined, :undefined, 2, 1, 1, :undefined, :undefined},
       {:type, :"ser:RecommendedItem", :sequence,
        [
          {:el, [{:alt, :"ser:itemNo", {:"#PCDATA", :char}, [], 1, 1, true, :undefined}], 0, 1,
           true, 3},
          {:el, [{:alt, :"ser:lift", {:"#PCDATA", :char}, [], 1, 1, true, :undefined}], 0, 1,
           :undefined, 4}
        ], [], :undefined, :undefined, 3, 1, 1, :undefined, :undefined}
     ],
     [
       {:ns, 'http://lsretail.com/LSOmniService/Base/2021', 'ser', :qualified},
       {:ns, 'http://lsretail.com/LSOmniService/EComm/2017/Service', 'ser', :qualified},
       {:ns, 'http://lsretail.com/LSOmniService/EComm/2017/Service/Imports', :undefined,
        :unqualified},
       {:ns, 'http://lsretail.com/LSOmniService/Loy/2021', 'ser', :qualified},
       {:ns, 'http://www.w3.org/2001/XMLSchema', 'xsd', :qualified}
     ], 'http://lsretail.com/LSOmniService/EComm/2017/Service/Imports', [], true, :skip}
  end
end
