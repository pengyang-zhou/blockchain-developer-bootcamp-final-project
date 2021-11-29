import Web3 from 'web3';
//@ts-ignore
import EthDonation from './EthDonation.json';

//@ts-ignore
const web3 = new Web3(window.ethereum);
const contract = new web3.eth.Contract(EthDonation.abi, '0xC374e9F0df4069bE84Ce2ad97237379E9838b2f4');

function detectWallet() {
    //@ts-ignore
    if (typeof window.ethereum !== 'undefined') {
        console.log('MetaMask has been detected');
        return true;
    } else {
        console.log("No wallet installed!");
        return false;
    }
}

function addListener(fn: Function) {
    //@ts-ignore
    window.ethereum.on('accountsChanged', fn)
}

async function connect() {
    //@ts-ignore
    await window.ethereum.enable();
}

async function getAccount() {
    return (await web3.eth.getAccounts())[0];
}

export interface Project {
    index: number,
    founder: string,
    title: string,
    description: string,
    endTime: string,
    amountFunded: number,
    amountAllocated: number,
    expenseCount: number
}

export declare interface Expense {
    index: number,
    description: string,
    allocation: string,
    approvedAmount: string,
    state: number
}

export declare interface Donation {
    donator: string,
    total: string,
    available: string
}

async function getProjects() : Promise<Project[]> {
    const projectCount = await contract.methods.projectCount().call();
    const projects = [];
    for (let i=1; i<=projectCount; i++) {
        projects.push(await getProject(i));
    }
    return projects;
}

async function getProject(index:number) : Promise<Project> {
    const data = await contract.methods.projects(index).call();
    data.amountFunded = Web3.utils.fromWei(data.amountFunded, 'ether');
    data.amountAllocated = Web3.utils.fromWei(data.amountAllocated, 'ether');
    return {index, ...data};
}

async function getExpenseCount(projectId:number) : Promise<number> {
    return await contract.methods.getExpenseCount(projectId).call();
}

async function getProjectExpenses(projectId:number) : Promise<Expense[]> {
    const expenseCount = await getExpenseCount(projectId);
    const expenses : Expense[] = [];
    for(let i=1; i<=expenseCount; i++) {
        const expense = await contract.methods.getExpense(projectId, i).call();
        expenses.push({
            index: i,
            description: expense[0],
            allocation: Web3.utils.fromWei(expense[1], 'ether'),
            approvedAmount: Web3.utils.fromWei(expense[2], 'ether'),
            state: expense[3]
        });
    }
    return expenses;
}

async function getProjectDonations(projectId: number) : Promise<Donation[]> {
    const data = await contract.methods.getDonations(projectId).call();
    const donationCount = data[0].length;
    const donations : Donation[] = [];
    for(let i=0; i<donationCount; i++) {
        donations.push({
            donator: data[0][i],
            total: Web3.utils.fromWei(data[1][i], 'ether'),
            available: Web3.utils.fromWei(data[2][i], 'ether'),
        });
    }
    return donations;
}

async function createProject(title:string, description:string, endTime:number, account:string) {
    return await contract.methods.createProject(title, description, endTime).send({
        from: account,
        gas: 1000000
    });
}

async function createExpense(projectId: number, description:string, allocation: string) {
    const account = await getAccount();
    allocation = Web3.utils.toWei(allocation, 'ether')
    return await contract.methods.createExpense(projectId, allocation, description).send({
        from: account,
        gas: 1000000
    });
}

async function donate(id:number, value:string) {
    if (!isNumeric(value)) {
        throw TypeError("value must be a valid numeric string");
    }
    const account = await getAccount();
    return await contract.methods.donate(id).send({
        from: account,
        value: Web3.utils.toWei(value, 'ether')
    });
}

function isNumeric(input: string){
    var RE = /^-{0,1}\d*\.{0,1}\d+$/;
    return (RE.test(input));
}

async function approveExpense(projectId:number, expenseId:number) : Promise<number>{
    const account = await getAccount();
    return await contract.methods.approveExpense(projectId, expenseId).send({
        from: account,
        gas: 1000000
    });
}

export {
    detectWallet,
    getAccount,
    connect,
    contract,
    addListener,
    getProjects,
    getProject,
    getProjectExpenses,
    getProjectDonations,
    createProject,
    donate,
    approveExpense,
    createExpense
}

