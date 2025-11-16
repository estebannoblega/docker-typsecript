import { RowDataPacket } from "mysql2"

export type UserRow = RowDataPacket & {
    idUsuario: number,
    email?: string,
    password: string,
}

