import { createClient } from '@/lib/supabase';
import { Metadata, ResolvingMetadata } from 'next';
import { notFound } from 'next/navigation';
import { Utensils } from 'lucide-react';

interface PageProps {
  params: { id: string };
}

interface Estabelecimento {
  cnpj: string;
  nome_estabelecimento: string;
}

interface Prato {
  id: number;
  nome_prato: string;
  valor_prato: number;
  categoria_prato: string;
  id_estabelecimento: string;
}

interface CategoriaAgrupada {
  nome: string;
  pratos: Prato[];
}

export async function generateMetadata(
  { params }: PageProps,
  parent: ResolvingMetadata
): Promise<Metadata> {
  const supabase = createClient();
  const idDoEstabelecimento = params.id;

  const { data: estabelecimentoData, error } = await supabase
    .from('estabelecimentos')
    .select('nome_estabelecimento')
    .eq('cnpj', idDoEstabelecimento)
    .single();

  if (error || !estabelecimentoData) {
    console.error("Erro generateMetadata:", error);
    return {
      title: 'Cardápio não encontrado | Techbistro',
    };
  }

  return {
    title: `${estabelecimentoData.nome_estabelecimento} - Cardápio Digital | Techbistro`,
  };
}

export default async function CardapioPage({ params }: PageProps) {
  const supabase = createClient();
  const idDoEstabelecimento = params.id;

  const { data: estabelecimento, error: estabelecimentoError } = await supabase
    .from('estabelecimentos')
    .select('cnpj, nome_estabelecimento')
    .eq('cnpj', idDoEstabelecimento)
    .single<Estabelecimento>();

  if (estabelecimentoError || !estabelecimento) {
    console.error("Erro ao buscar estabelecimento:", estabelecimentoError);
    notFound();
  }

  console.log(`Buscando pratos para id_estabelecimento: ${idDoEstabelecimento}`);
  const { data: pratos, error: pratosError } = await supabase
    .from('pratos')
    .select('id, nome_prato, valor_prato, categoria_prato, id_estabelecimento')
    .eq('id_estabelecimento', idDoEstabelecimento);

  if (pratosError) {
    console.error("Erro detalhado ao buscar pratos:", pratosError);
  } else {
    console.log(`Encontrados ${pratos ? pratos.length : 0} pratos.`);
  }

  const listaDePratos = pratos ?? [];

  const categoriasAgrupadas: Record<string, Prato[]> = {};
  listaDePratos.forEach((prato) => {
    const categoriaNome = prato.categoria_prato || 'Outros';
    if (!categoriasAgrupadas[categoriaNome]) {
      categoriasAgrupadas[categoriaNome] = [];
    }
    categoriasAgrupadas[categoriaNome].push(prato);
  });

  const categoriasParaRenderizar: CategoriaAgrupada[] = Object.entries(categoriasAgrupadas)
    .map(([nome, pratos]) => ({ nome, pratos }))
    .sort((a, b) => a.nome.localeCompare(b.nome));

  return (
    <div className="min-h-screen bg-[#F8F8F8] dark:bg-gray-900 font-sans text-dark-text dark:text-light-text">
      <header className="bg-brand-red text-white p-4 shadow-md sticky top-0 z-50 flex items-center justify-center">
        <h1 className="text-xl font-semibold text-center">{estabelecimento.nome_estabelecimento}</h1>
      </header>

      <main className="container mx-auto p-3 sm:p-4 md:p-6 pb-16">
        {categoriasParaRenderizar.length === 0 ? (
          <p className="text-center text-gray-500 dark:text-gray-400 mt-10">Nenhum item encontrado no cardápio.</p>
        ) : (
          categoriasParaRenderizar.map((categoria) => (
            <section key={categoria.nome} className="mb-8">
              <h2 className="text-lg font-bold mb-4 text-brand-red pl-2">
                {categoria.nome}
              </h2>

              <div className="space-y-3">
                {categoria.pratos.length === 0 ? (
                  <p className="text-gray-500 dark:text-gray-400 pl-2">Nenhum produto nesta categoria.</p>
                ) : (
                  categoria.pratos.map((prato) => (
                    <div
                      key={prato.id}
                      className="bg-white dark:bg-gray-800 rounded-lg shadow-sm overflow-hidden flex items-center p-3 gap-3"
                    >
                      <div className="flex-shrink-0 w-16 h-16 bg-gray-200 dark:bg-gray-700 flex items-center justify-center text-gray-400 rounded">
                           <Utensils size={24} />
                      </div>

                      <div className="flex-grow flex flex-col justify-between self-stretch">
                        <div>
                           <h3 className="text-base sm:text-lg font-semibold text-dark-text dark:text-light-text mb-1 line-clamp-2">
                             {prato.nome_prato}
                           </h3>
                        </div>
                        <p className="text-base sm:text-lg font-bold text-brand-red mt-1 self-end">
                          R$ {prato.valor_prato.toFixed(2).replace('.', ',')}
                        </p>
                      </div>
                    </div>
                  ))
                )}
              </div>
            </section>
          ))
        )}
      </main>
    </div>
  );
}

