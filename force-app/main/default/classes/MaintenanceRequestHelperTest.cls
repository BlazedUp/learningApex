@isTest
public with sharing class MaintenanceRequestHelperTest {
    @TestSetup
    static void makeData(){
        Account newAcc = new Account();
        newAcc.name = 'TestAcc1';
        insert newAcc;

        Contact newCon = new Contact();
        newCon.FirstName = 'TestCon';
        newCon.LastName = 'TestCon';
        newCon.Email = 'testcon@mail.com';
        newCon.AccountId = newAcc.Id;
        insert newCon;
 
        Vehicle__c newVeh = new Vehicle__c();
        newVeh.name = 'Bugatti Veyron';
        insert newVeh;

        Product2 newProduct = new Product2();
        newProduct.Name = 'TestProduct';
        newProduct.isActive = true;
        newProduct.Maintenance_Cycle__c = 10;
        newProduct.Replacement_Part__c = true;
        insert newProduct;

        Product2 newProduct2 = new Product2();
        newProduct2.Name = 'TestProduct2';
        newProduct2.isActive = true;
        newProduct2.Replacement_Part__c = true;
        insert newProduct2;
    }

    @IsTest
    static void updateWorkOrdersTest(){

    List<Case> caseList = new List<Case>();
    List<Case> secondList = new List<Case>();
    List<Equipment_Maintenance_Item__c> newItems = new List<Equipment_Maintenance_Item__c>();

    
    Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAcc1' LIMIT 1]; 
    Contact contact  = [SELECT Id, FirstName, LastName,Email,AccountId FROM Contact WHERE Email = 'testcon@mail.com' LIMIT 1]; 
    Vehicle__c vehicle = [SELECT Id, Name FROM Vehicle__c WHERE Name = 'Bugatti Veyron' LIMIT 1]; 
    Product2 product = [SELECT Id, Name, isActive, Maintenance_Cycle__c, Replacement_Part__c FROM Product2 WHERE Name = 'TestProduct' LIMIT 1]; 
    Product2 product2 = [SELECT Id, Name, isActive, Maintenance_Cycle__c, Replacement_Part__c FROM Product2 WHERE Name = 'TestProduct2' LIMIT 1];         

    Test.startTest();
            
    for(Integer i=1;i<=300;i++){
  
        Case maintenanceNew             = new Case();
        maintenanceNew.Subject          = 'Other';
        maintenanceNew.Vehicle__c       = vehicle.Id;
        maintenanceNew.ContactId        = contact.Id;
        maintenanceNew.AccountId        = acc.Id;
        maintenanceNew.Type             = 'Other';
        maintenanceNew.Status           = 'New';
        maintenanceNew.Date_Reported__c = Date.today();
        maintenanceNew.Date_Due__c      = Date.today();
                
        caseList.add(maintenanceNew);
        }
            
        insert caseList;
            
        System.assertEquals(300,caseList.size());

        List<Case> createdCases = [Select Id, Date_Due__c from Case where Subject = 'Other'];
        Integer i = 1;
        for(Case cas : createdCases){
            Product2 currentProduct = new Product2();
            Equipment_Maintenance_Item__c newItem = new Equipment_Maintenance_Item__c();

            if (math.mod(i, 2) == 0 ) {
                currentProduct = product;
            } else {
                currentProduct = product2;
            }
            newItem.Maintenance_Request__c = cas.Id;
            newItem.Equipment__c = currentProduct.Id;
            newItems.add(newItem);

                cas.Type = 'Repair';
                cas.Status = 'Closed';
                secondList.add(cas);
            i++;
            }
            
            insert newItems;
            update secondList;

            System.assertEquals(300,createdCases.size());

            Test.stopTest();
    } 
}