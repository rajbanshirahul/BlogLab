export class ApplicationUser {

    constructor(
        public applicationUserId: number,
        public username: string,
        public password: string,
        public email: string,
        public token: string
    ) { }
}