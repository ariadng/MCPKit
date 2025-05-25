/**
 * A known resource that the server is capable of reading.
 */
import { Annotations } from './Annotations';

export interface Resource {
  /**
   * The URI of the resource. The URI can use any protocol; it is up to the server how to interpret it.
   * 
   * @format uri
   */
  uri: string;
  
  /**
   * A human-readable name for the resource.
   */
  name: string;
  
  /**
   * An optional human-readable description of the resource.
   */
  description?: string;
  
  /**
   * The MIME type of the resource, if known.
   */
  mimeType?: string;
  
  /**
   * Optional annotations for the client.
   */
  annotations?: Annotations;
  
  /**
   * The size of the resource in bytes, if known.
   * 
   * @TJS-type number
   */
  size?: number;
}
