import { describe, it, expect, beforeEach } from 'vitest';

// Mock for the simulations storage
let simulations: Map<number, {
  creator: string,
  name: string,
  description: string,
  parameters: Array<{ name: string, value: string }>,
  status: string
}> = new Map();
let nextSimulationId = 0;

// Helper function to simulate contract calls
const simulateContractCall = (functionName: string, args: any[], sender: string) => {
  if (functionName === 'create-simulation') {
    const [name, description, parameters] = args;
    const simulationId = nextSimulationId++;
    simulations.set(simulationId, { creator: sender, name, description, parameters, status: 'pending' });
    return { success: true, value: simulationId };
  }
  if (functionName === 'get-simulation') {
    const [simulationId] = args;
    return simulations.get(simulationId) || null;
  }
  if (functionName === 'update-simulation-status') {
    const [simulationId, newStatus] = args;
    const simulation = simulations.get(simulationId);
    if (simulation && simulation.creator === sender) {
      simulation.status = newStatus;
      simulations.set(simulationId, simulation);
      return { success: true };
    }
    return { success: false, error: 'Not authorized or simulation not found' };
  }
  return { success: false, error: 'Function not found' };
};

describe('Simulation Parameters Contract', () => {
  const wallet1 = 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM';
  const wallet2 = 'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG';
  
  beforeEach(() => {
    simulations.clear();
    nextSimulationId = 0;
  });
  
  it('should create a simulation', () => {
    const result = simulateContractCall('create-simulation', [
      'Test Simulation',
      'A test simulation for panspermia',
      [{ name: 'gravity', value: '9.8' }, { name: 'atmosphere', value: 'oxygen-rich' }]
    ], wallet1);
    expect(result.success).toBe(true);
    expect(result.value).toBe(0);
  });
  
  it('should retrieve a simulation', () => {
    simulateContractCall('create-simulation', [
      'Get Test',
      'Testing get function',
      [{ name: 'test', value: 'value' }]
    ], wallet1);
    const result = simulateContractCall('get-simulation', [0], wallet1);
    expect(result).toBeDefined();
    expect(result?.name).toBe('Get Test');
  });
  
  it('should update simulation status', () => {
    simulateContractCall('create-simulation', [
      'Update Test',
      'Testing update function',
      [{ name: 'test', value: 'value' }]
    ], wallet1);
    const updateResult = simulateContractCall('update-simulation-status', [0, 'completed'], wallet1);
    expect(updateResult.success).toBe(true);
    const getResult = simulateContractCall('get-simulation', [0], wallet1);
    expect(getResult?.status).toBe('completed');
  });
  
  it('should not allow unauthorized status updates', () => {
    simulateContractCall('create-simulation', [
      'Unauthorized Test',
      'Testing unauthorized update',
      [{ name: 'test', value: 'value' }]
    ], wallet1);
    const updateResult = simulateContractCall('update-simulation-status', [0, 'completed'], wallet2);
    expect(updateResult.success).toBe(false);
  });
});
