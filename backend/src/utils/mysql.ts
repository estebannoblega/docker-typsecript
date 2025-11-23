/**
 * Utilidad para dar un tipado al resultado de las llamadas a los procedimientos almacendados de usuarios
 */
export function unpackCallResult<T>(result: any):T[] {
    return result[0] as T[]
}
