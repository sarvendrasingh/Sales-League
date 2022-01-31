import { LightningElement, track } from 'lwc';
import currentFY from '@salesforce/apex/leaderboardController.currentFY';
import targetQuarterOptions from '@salesforce/apex/leaderboardController.targetQuarterOptions';
import targetQuarterRange from '@salesforce/apex/leaderboardController.targetQuarterRange';
import awardFYDateRanges from '@salesforce/apex/leaderboardController.awardFYDateRanges';
import awardFQDateRanges from '@salesforce/apex/leaderboardController.awardFQDateRanges';

export default class LeaderboardFilter extends LightningElement {
    radioValue = 'TARGETS';
    TargetsSelected = true;
    @track toDate;
    @track fromDate;
    nonCustom = true;
    selectQuarter = false;
    @track selectedQuarter;
    targetValue = 'currentFY';
    awardValue = 'FY';

    awardQuarter = false;
    @track awardFY;
    @track awardFQ;

    //values to pass as parameter
    toDateParam;
    fromDateParam;

    quarterOptions = [];
    awardFYDateRanges = [];
    awardFQDateRanges = [];

    connectedCallback() {
        this.populateTargetFY();
    }

    get options() {
        return [
            { label: 'Filter targets', value: 'TARGETS' },
            { label: 'Awarded Members', value: 'AWARDS' },
        ];
    }

    radioValueChange(event){
        var selectedRadioOption = event.detail.value;
        this.radioValue = selectedRadioOption;
        if(selectedRadioOption == "AWARDS"){
            this.TargetsSelected = false;
            this.awardFY = "";
            this.awardFQ = "";
            this.populateAwardFY();
        }
        else{
            this.TargetsSelected = true;
        }
    }

    get targetsOptions() {
        return [
            { label: 'Current FY', value: 'currentFY' },
            { label: 'Quarter', value: 'QUARTER' },
            { label: 'Custom', value: 'CUSTOM' },
        ];
    }

    get awardsOption() {
        return [
            { label: 'Financial Year', value: 'FY' },
            { label: 'Financial Quarter', value: 'FQ' },
        ];
    }

    handleTargetChange(event){
        this.targetValue = event.detail.value;
        if (this.targetValue == "CUSTOM") {
            this.nonCustom = false;
            this.selectQuarter = false;
            this.fromDate = "";
            this.toDate = "";

        } else if(this.targetValue == "QUARTER"){
            this.nonCustom = true;
            this.selectQuarter = true;
            this.fromDate = "";
            this.toDate = "";
            this.quarterOptions = [];
            targetQuarterOptions()
                .then(result => { 
                    let op = Object.entries(result).map(([label, value]) => ({ label, value }));
                    this.quarterOptions = op;
                    for (const key in result) {
                        this.selectedQuarter = result[key];
                    }
                    this.populateTargetQuarter();
                });
        }
        else {
            this.nonCustom = true;
            this.selectQuarter = false;
            this.populateTargetFY();
        }
    }

    get quartersOptions() {  
        return this.quarterOptions;
    }

    handleQuarterChange(event) {
        this.selectedQuarter = event.detail.value;
        this.populateTargetQuarter();
    }

    populateTargetQuarter(){
        targetQuarterRange({ targetQuarterSelected: this.selectedQuarter })
            .then(result => {
                this.fromDate = result[0];
                this.toDate = result[1];
            });
    }

    populateTargetFY() {
        currentFY()
            .then(result => {
                this.fromDate = result[0];
                this.toDate = result[1];
            });
    }

    populateAwardFY() {
        awardFYDateRanges()
                .then(result => {
                    let op = Object.entries(result).map(([label, value]) => ({ label, value }));
                    this.awardFYDateRanges = op;
                    for (const key in result) {
                        this.awardFY = result[key];
                    }
                    if (this.awardValue == "FQ") {
                        this.populateAwardFQ();
                    }
                });
    }

    populateAwardFQ() {
        awardFQDateRanges({ awardFYSelected : this.awardFY })
            .then(result => {
                let op = Object.entries(result).map(([label, value]) => ({ label, value }));
                this.awardFQDateRanges = op;
                for (const key in result) {
                    this.awardFQ = result[key];
                }
            });
    }

    get awardsFYOption() {
        return this.awardFYDateRanges;
    }

    handleToDateChange(event){
        this.toDate = event.target.value;
    }

    handleFromDateChange(event){
        this.fromDate = event.target.value;
    }
    
    handleAwardChange(event){
        this.awardValue = event.detail.value;
        this.awardFQ = "";
        this.awardFQDateRanges = "";
        this.awardFY = "";
        if (this.awardValue == "FQ") {
            this.awardQuarter = true;
        } else {
            this.awardQuarter = false;
        }
        this.populateAwardFY();
    }

    get awardsFQOption() {
        return this.awardFQDateRanges;
    }

    handleAwardFYChange(event) {
        this.awardFY = event.detail.value;
        this.populateAwardFQ();
    }
    
    handleAwardFQChange(event) {
        this.awardFQ = event.detail.value;
    }

    searchTarget() {
        this.toDateParam = this.toDate;
        this.fromDateParam = this.fromDate;
        this.passToChild();
    }

    searchAward() {
        var myList;
        var text = "";
        if (this.awardValue == "FQ") {
            text = this.awardFQ;
        } else {
            text = this.awardFY;
        }
        myList = text.split("=");
        this.toDateParam = myList[1].substring(0,10);
        this.fromDateParam = myList[0].substring(0, 10);
        this.passToChild();
    }

    passToChild() {
        if (this.toDateParam != "" && this.fromDateParam != "") {
            console.log("To Date Passed: " + this.toDateParam + "\n"+ "From Date Passed: " + this.fromDateParam );
        } else {
            console.log("Populate fields first.");
        }
    }

}   