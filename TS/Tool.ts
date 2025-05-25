/**
 * Definition for a tool the client can call.
 */
import { ToolAnnotations } from './ToolAnnotations';

export interface Tool {
  /**
   * The name of the tool.
   */
  name: string;
  
  /**
   * An optional human-readable description of the tool.
   */
  description?: string;
  
  /**
   * The schema for the input to the tool.
   */
  inputSchema: {
    type: "object";
    properties?: { [key: string]: object };
    required?: string[];
  };
  
  /**
   * Optional additional tool information.
   */
  annotations?: ToolAnnotations;
}
