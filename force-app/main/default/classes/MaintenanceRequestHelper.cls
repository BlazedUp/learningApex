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
                cloneItems(inputCases,createdCasesMap);
            }
    }
    public static  Map<String,Integer> getDueDate(List<Case> listCases){
        Map<String,Integer> result = new Map<String,Integer>();
        Map<Id, case> caseIDs = new Map<Id, case> (listCases);
        List<AggregateResult> queryProducts =    [SELECT Maintenance_Request__r.ID caseId, min(Equipment__r.Maintenance_Cycle__c) minCycle
                                                FROM Equipment_Maintenance_Item__c  where  Maintenance_Request__r.ID in :caseIDs.keySet() 
                                                WITH SECURITY_ENFORCED GROUP BY Maintenance_Request__r.ID ];
        for(AggregateResult res : queryProducts){
            Integer addDays = 0;
            if(res.get('minCycle') != null) {
                addDays += Integer.valueOf(res.get('minCycle'));
            }
                
            result.put(String.valueOf(res.get('caseId')),addDays);
        }
        return result;
    }
    public static void cloneItems(List<Case> closedCases, Map<Id,case> newCasesMap){
        List<Equipment_Maintenance_Item__c> newItems = new List<Equipment_Maintenance_Item__c>();
            if(!closedCases.isEmpty() && newCasesMap.size() > 0){
                List<Equipment_Maintenance_Item__c> oldItems = [SELECT Equipment__c, Maintenance_Request__c, Quantity__c,Maintenance_Request__r.Id
                                                                     FROM Equipment_Maintenance_Item__c
                                                                     WHERE Maintenance_Request__c IN :closedCases];
                
                for(Equipment_Maintenance_Item__c item : oldItems) {
                    
                    Equipment_Maintenance_Item__c newItem = item.clone(false, true, false, false);
                    newItem.Maintenance_Request__c = newCasesMap.get(item.Maintenance_Request__c).Id;
                    newItems.add(newItem);
                }
                insert newItems;
            }
    }
}