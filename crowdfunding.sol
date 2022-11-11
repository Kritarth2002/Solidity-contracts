pragma solidity >=0.5.0 <0.9.0;
contract crowdFunding{
    mapping(address=>uint) public contributors;
    uint public target;
    uint public deadline;
    uint public minContribution;
    uint public raisedAmount;
    uint public noofContributors;
    address public manager;

    constructor(uint _target,uint _ deadline){
        target=_target;
        deadline=block.timestamp+_deadline;
        manager=msg.sender;
        minContribution=100 wei;
    }
    struct Requests{
        string description;
        address payable reciepent;
        uint value;
        bool completed;
        uint noOfVoters;
        mapping(address=>bool) votelist;
    }
    mapping(uint=>Requests) public requests;
    uint public numRequests;

    function sendEth() public payable{
        require(block.timestamp<deadline,"deadline is passed");
        require(msg.value>=minContribution,"kindly send amound greater than min contribution");
        if(contributors[msg.sender]==0)
        {
            noofContributors++;
        }
        contributors[msg.sender]+=msg.value;
        raisedAmount+=msg.value;
    }
    function getContractBalance() view public returns(uint){
        return address(this).balance;
    }
    function refund() public{
        require(contributors[msg.sender]!=0,"you should be a contributor");
        require(block.timestamp>deadline && raisedAmount<target,"you are not eligible for refund");
       payable( msg.sender).transfer(contributors[msg.sender]);
       contributors[msg.sender]=0;
    }
    modifier onlyManager(){
        require(msg.sender==manager,"only manager can call");
        _;
    }
    function createRequest(string memory _description,address payable _reciepent,uint _value) onlyManager public{
        Requests storage user=requests[numRequests];
        user.description=_description;
        user.reciepent=_reciepent;
        user.value=_value;
        user.completed=false;
        user.noOfVoters=0;
        numRequests++;
    }
    function voteRequest(uint _requestNo) public{
        require(contributors[msg.sender]>0,"contribute first");
        Requests storage user1=requests[_requestNo];
        require(user1.votelist[msg.sender]==false,"you have already voted");
        user1.noOfVoters++;
        user1.votelist[msg.sender]=true;


    }
    function makePayment(uint _requestNo) public onlyManager payable
    {
        require(requests[_requestNo].completed==false,"request has been completed");
        require(raisedAmount>=target);
        require(requests[_requestNo].noOfVoters>noofContributors/2,"marjority does not want the request to be completed");
        // Requests storage user1=requests[_requestNo];
        address payable user=payable(requests[_requestNo].reciepent);
        user.transfer(requests[_requestNo].value);
        requests[_requestNo].completed=true;

    }
}