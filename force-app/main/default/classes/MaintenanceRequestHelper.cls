public with sharing class MaintenanceRequestHelper {
    public static void updateWorkOrders(List<Case> inputCases) {
        List<Case> casesToCreate = new List<Case>();
        Map<String,Integer> result = getDueDate(inputCases);
        Map<Id,Case> createdCasesMap = new Map<Id,Case>();
        for(Case cs : inputCases){
            if(cs.Status == 'Closed') {
                if(cs.Type == 'Repair' || cs.Type=='Routine Maintenance') {
                    Case c = new Case();
                    c.Status = 'New';
                    c.Origin = 'web';
                    c.Type = 'Routine Maintenance';
                    c.ContactId = cs.ContactId;
                    c.AccountId = cs.AccountId;
                    c.Vehicle__c = cs.Vehicle__c;
                    c.Subject = 'Routine Checkup ' + cs.CaseNumber;
                    c.ProductId = cs.ProductId;
                    c.Date_Reported__c = Date.today();
                    if(result.get(cs.Id) != null) {
                        c.Date_Due__c=Date.today()+result.get(cs.Id);
                    }
                    casesToCreate.add(c);
                    createdCasesMap.put(cs.Id, c);
                }
            }
        }
        insert casesToCreate;
        if(inputCases.size() > 0 && createdCasesMap.size() > 0){
            cloneEquipItems(inputCases,createdCasesMap);
        }
    }
    public static  Map<String,Integer> getDueDate(List<Case> listCases){
       Map<String,Integer> result = new Map<String,Integer>();
        Map<Id, case> caseIDs = new Map<Id, case> (listCases);
       List<AggregateResult> queryProducts =    [SELECT Maintenance_Request__r.ID cID, min(Equipment__r.Maintenance_Cycle__c) cycle
                                                FROM Equipment_Maintenance_Item__c  where  Maintenance_Request__r.ID in :caseIDs.keySet() 
                                                GROUP BY Maintenance_Request__r.ID];
        for(AggregateResult res : queryProducts){
            Integer addDays = 0;
            if(res.get('cycle') != null) {
                addDays += Integer.valueOf(res.get('cycle'));
            }
                
            result.put((String)res.get('cID'),addDays);
        }
        return result;
    }
    public static void cloneEquipItems(List<Case> closedCaseRecords, Map<Id,case> newCreatedCasesMap){
        List<Equipment_Maintenance_Item__c> newEquipItems = new List<Equipment_Maintenance_Item__c>();
        try{
            if(!closedCaseRecords.isEmpty() && newCreatedCasesMap.size() > 0){
                List<Equipment_Maintenance_Item__c> oldEquipItems = [SELECT Equipment__c, Maintenance_Request__c, Quantity__c,Maintenance_Request__r.Id
                                                                     FROM Equipment_Maintenance_Item__c
                                                                     WHERE Maintenance_Request__c IN :closedCaseRecords];
                
                for(Equipment_Maintenance_Item__c equipItem : oldEquipItems) {
                    
                    Equipment_Maintenance_Item__c newItem = equipItem.clone(false, true, false, false);
                    newItem.Maintenance_Request__c = newCreatedCasesMap.get(equipItem.Maintenance_Request__c).id;
                    newEquipItems.add(newItem);
                }
                insert newEquipItems;
            }
        }
        catch(Exception e){
            System.debug('Error creating Maintenance Items'+ e);
        }
    }
}