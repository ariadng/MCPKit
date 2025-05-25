/**
 * Hints to use for model selection.
 *
 * Keys not declared here are currently left unspecified by the spec and are up
 * to the client to interpret.
 */
export interface ModelHint {
  /**
   * The name of a specific model that the server would prefer to use.
   */
  name?: string;
}
