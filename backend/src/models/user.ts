import { hash } from "bcrypt";
import { email, minLength, object, pipe, string, type InferInput } from "valibot";

//En lugar de usar el tipo de dato usamos un esquema, ya que va a permitir definir qué caracteríticas tendrá el objeto, por ejemplo si el string es requerido, si tiene un patron específico, etc. 
const emailSchema = pipe(string(),email());
const passwordSchema = pipe(string(),minLength(8));

export const authSchema = object ({
    email: emailSchema,
    password: passwordSchema
});

//aqui creo un tipo de typescript usando el esquema creado arriba
export type User = InferInput <typeof authSchema> & {
    id: number,
    refreshtoken?: string
}


/**
 * EJEMPLO DE MODELADO DE USUARIO
 */
const users:Map<String, User>=new Map();

/**
 * Creates a new user with the given email and password.
 * The password is hashed before storing.
 * @param {string} email - The email of the user
 * @param {string} password - The password of the user
 * @returns {Promise<User>} - The created user
 */
export const createUser = async (
    email:string,
    password: string
):Promise<User>=>{
    const hashedPassword = await hash(password,10);
    const newUser: User = {
        id: Date.now(),
        email,
        password: hashedPassword
    }
    users.set(email,newUser);

    return newUser;
};